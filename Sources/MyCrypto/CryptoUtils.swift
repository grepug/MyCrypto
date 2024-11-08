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
    
    public static func encrypt<T: Codable>(object: T, publicKeyPEM: String) throws -> String {
        // Convert the object to JSON data
        let jsonData = try JSONEncoder().encode(object)

        // Convert PEM encoded public key to SecKey
        guard let publicKey = try? convertPEMToPublicKey(pemString: publicKeyPEM) else {
            throw EncryptionError.invalidPublicKey
        }

        // Encrypt the data
        let encryptedData = try publicKey.encrypt(data: jsonData)

        // Convert encrypted data to base64 string
        let base64String = encryptedData.base64EncodedString()

        return base64String
    }

    private static func convertPEMToPublicKey(pemString: String) throws -> P256.KeyAgreement.PublicKey {
        let keyString =
            pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let keyData = Data(base64Encoded: keyString) else {
            throw EncryptionError.invalidPublicKey
        }

        return try! P256.KeyAgreement.PublicKey(rawRepresentation: keyData) 
    }

    enum EncryptionError: Error {
        case invalidPublicKey
    }

    enum DecryptionError: Error {
        case invalidBase64String
        case invalidPrivateKey
        case invalidDecryptedData
    }

    public static func decrypt(encryptedString: String, privateKeyPEM: String) throws -> Data {
        // Decode the base64 encoded encrypted string
        guard let encryptedData = Data(base64Encoded: encryptedString) else {
            throw DecryptionError.invalidBase64String
        }

        // Convert PEM encoded private key to SecKey
        guard let privateKey = try? convertPEMToPrivateKey(pemString: privateKeyPEM) else {
            throw DecryptionError.invalidPrivateKey
        }

        // Decrypt the data
        let decryptedData = try privateKey.decrypt(data: encryptedData)

        return decryptedData
    }

    private static func convertPEMToPrivateKey(pemString: String) throws -> P256.KeyAgreement.PrivateKey {
        let keyString =
            pemString
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let keyData = Data(base64Encoded: keyString) else {
            throw DecryptionError.invalidPrivateKey
        }

        return try P256.KeyAgreement.PrivateKey(rawRepresentation: keyData)
    }
}

extension P256.KeyAgreement.PublicKey {
    func encrypt(data: Data) throws -> Data {
        let ephemeralKey = P256.KeyAgreement.PrivateKey()
        let sharedSecret = try ephemeralKey.sharedSecretFromKeyAgreement(with: self)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
                                                               salt: Data(),
                                                               sharedInfo: Data(),
                                                               outputByteCount: 32)
        let sealedBox = try ChaChaPoly.seal(data, using: symmetricKey)
        return sealedBox.combined
    }
}

extension P256.KeyAgreement.PrivateKey {
    func decrypt(data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let ephemeralPublicKey = try ChaChaPoly.SealedBox(combined: data).nonce
        let sharedSecret = try self.sharedSecretFromKeyAgreement(with: P256.KeyAgreement.PublicKey(rawRepresentation: ephemeralPublicKey))
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self,
                                                               salt: Data(),
                                                               sharedInfo: Data(),
                                                               outputByteCount: 32)
        return try ChaChaPoly.open(sealedBox, using: symmetricKey)
    }
}
