import Foundation
import Testing

@testable import MyCrypto

//@Test func gen() async throws {
//    let (privateKeyPEM, publicKeyPEM) = CryptoUtils.generateKeyPair()
//    print("privateKeyPEM: \(privateKeyPEM)")
//    print("publicKeyPEM: \(publicKeyPEM)")
//}

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    let publicKeyPEM = "n53H4kpR9CSk/Ad/YHRUYHECcxODl5BLC90jLfKL0+XEjl49g7J00ZiAkd/RhXWAHstqPRUTlUbWIykhPokpEA=="

    
    let dtoo = ["name": "kai", "sirname": "shao"]
    let encryptedData = try CryptoUtils.encrypt(
        dtoo, publicKey: publicKeyPEM)
    var urlRequest = URLRequest(
        url: URL(string: "http://localhost:8081/v1/test")!)
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = encryptedData

    let (data, _) = try await URLSession.shared.data(for: urlRequest)
    let dtooo = try JSONDecoder().decode([String: String].self, from: data)

    #expect(dtoo == dtooo)
}
