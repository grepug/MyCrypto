import Foundation
import Testing

@testable import MyCrypto

@Test func gen() async throws {
    let (privateKeyPEM, publicKeyPEM) = CryptoUtils.generateKeyPair()
    print("privateKeyPEM: \(privateKeyPEM)")
    print("publicKeyPEM: \(publicKeyPEM)")
}

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    let publicKeyPEM = """
        -----BEGIN PUBLIC KEY-----
        n53H4kpR9CSk/Ad/YHRUYHECcxODl5BLC90jLfKL0+XEjl49g7J00ZiAkd/RhXWAHstqPRUTlUbWIykhPokpEA==
        -----END PUBLIC KEY-----
        """

    
    let dtoo = ["name": "kai", "sirname": "shao"]
    let dto = EncryptedBody(
        timestamp: Date().timeIntervalSince1970,
        jsonData: try JSONEncoder().encode(dtoo)
    )
    let encrypted = try CryptoUtils.encrypt(
        object: dto, publicKeyPEM: publicKeyPEM)
    var urlRequest = URLRequest(
        url: URL(string: "http://localhost:8081/v1/test")!)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = encrypted.data(using: .utf8)

    let (data, _) = try await URLSession.shared.data(for: urlRequest)
    let dtooo = try JSONDecoder().decode([String: String].self, from: data)

    #expect(dtoo == dtooo)
}
