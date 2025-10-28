//
//  CryptoUtils.swift
//  MyCrypto
//
//  Created by Kai Shao on 2024/11/8.
//

import Crypto
import Foundation

public enum CryptoUtils {
    public static func generateKeyPair() -> (String, String) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        let privateKeyPEM = privateKey.rawRepresentation.base64EncodedString()
        let publicKeyPEM = publicKey.rawRepresentation.base64EncodedString()
        return (privateKeyPEM, publicKeyPEM)
    }

    public static func encrypt<T: Codable>(_ object: T, publicKey: String) throws -> Data {
        let message = try JSONEncoder().encode(object)
        let messageString = String(data: message, encoding: .utf8)!
        let data = try encrypt(message: messageString, publicKey: publicKey)

        return data
    }

    public static func encrypt(message: String, publicKey: String) throws -> Data {
        let publicKeyData = Data(base64Encoded: publicKey)!
        // Convert the server's public key data to a P256 public key
        let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)

        // Generate an ephemeral private key for key agreement
        let ephemeralPrivateKey = P256.KeyAgreement.PrivateKey()
        let ephemeralPublicKey = ephemeralPrivateKey.publicKey

        // Perform key agreement to derive a shared secret
        let sharedSecret = try ephemeralPrivateKey.sharedSecretFromKeyAgreement(with: publicKey)

        // Derive a symmetric key from the shared secret
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        // Create a timestamp
        let timestamp = Date().timeIntervalSince1970
        let messageWithTimestamp = "\(message)|\(timestamp)"
        let messageData = messageWithTimestamp.data(using: .utf8)!

        // Encrypt the message data using the symmetric key
        let sealedBox = try ChaChaPoly.seal(messageData, using: symmetricKey)

        // Combine the ephemeral public key and the sealed box
        var combinedData = Data()
        combinedData.append(ephemeralPublicKey.rawRepresentation)
        combinedData.append(sealedBox.combined)

        return combinedData
    }

    public static func decrypt(data: Data, privateKeyString: String) throws -> Data {
        let privateKey = try P256.KeyAgreement.PrivateKey(rawRepresentation: Data(base64Encoded: privateKeyString)!)

        // Extract the ephemeral public key from the data
        let ephemeralPublicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: data.prefix(64))

        // Perform key agreement to derive a shared secret
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)

        // Derive a symmetric key from the shared secret
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )

        // Extract the encrypted data (sealed box) from the remaining part of the input data
        let sealedBox = try ChaChaPoly.SealedBox(combined: data.dropFirst(64))

        // Decrypt the sealed box using the derived symmetric key
        let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)

        // Convert decrypted data to string
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.invalidDecryptedData
        }

        // Split the message and timestamp
        let components = decryptedString.split(separator: "|")
        guard components.count == 2, let message = components.first, let timestampString = components.last, let timestamp = TimeInterval(timestampString) else {
            throw CryptoError.invalidMessageFormat
        }

        // Verify the timestamp
        let currentTime = Date().timeIntervalSince1970
        guard abs(currentTime - timestamp) <= 30 else {
            throw CryptoError.timestampNotWithinRange
        }

        return String(message).data(using: .utf8)!
    }

    public enum CryptoError: Error {
        case invalidDecryptedData
        case invalidMessageFormat
        case timestampNotWithinRange
    }
}
