//
//  CryptoUtils.swift
//  MyCrypto
//
//  Created by Kai Shao on 2024/11/8.
//

import Crypto
import Foundation

public enum CryptoUtils {
    public static func encrypt<T: Codable>(object: T, publicKeyPEM: String) throws -> String {
        // Convert the object to JSON data
        let jsonData = try JSONEncoder().encode(object)

        // Convert PEM encoded public key to SecKey
        guard let publicKey = try? convertPEMToPublicKey(pemString: publicKeyPEM) else {
            throw EncryptionError.invalidPublicKey
        }

        // Encrypt the data
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, jsonData as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        // Convert encrypted data to base64 string
        let base64String = encryptedData.base64EncodedString()

        return base64String
    }

    private static func convertPEMToPublicKey(pemString: String) throws -> SecKey {
        let keyString =
            pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let keyData = Data(base64Encoded: keyString) else {
            throw EncryptionError.invalidPublicKey
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: NSNumber(value: 2048),
            kSecReturnPersistentRef as String: true,
        ]

        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }

        return publicKey
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
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionPKCS1, encryptedData as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        return decryptedData
    }

    private static func convertPEMToPrivateKey(pemString: String) throws -> SecKey {
        let keyString =
            pemString
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        print("keyString: \(keyString)")

        guard let keyData = Data(base64Encoded: keyString) else {
            throw DecryptionError.invalidPrivateKey
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 2048,
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                print("Error creating private key: \(error.localizedDescription)")
                throw error as Error
            } else {
                throw NSError(domain: "CryptoErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
            }
        }

        return privateKey
    }
}
