import Foundation
import Testing

@testable import MyCrypto

@Test func gen() async throws {
    let (privateKeyPEM, publicKeyPEM) = CryptoUtils.generateKeyPair()
    print("privateKeyPEM: \(privateKeyPEM)")
    print("publicKeyPEM: \(publicKeyPEM)")
}

@Test func example() async throws {
    let publicKeyPEM = "nVXtjH5OJJ/vEd4IgpFZiWgno1zUiGO2X/ZTbmwGwFSr3d3c/nSShNRArCp24tIvX0m8yEB/jAMawXSV0Li4DA=="

    
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
