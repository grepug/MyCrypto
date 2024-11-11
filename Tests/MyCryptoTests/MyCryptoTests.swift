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

@Test func dify() async throws {
    // needed to be removed later
    let key = "xxxxx"
    
    let inputs = Inputs(goal: "学英语")
    let dto = DifyParam<Inputs>.init(kind: "gen_goal", userId: "xxx", inputs: inputs, stream: false)
    var request = URLRequest(
        url: URL(string: "http://localhost:8081/v1/dify")!)
    request.httpMethod = "POST"
    let encrypted = try CryptoUtils.encrypt(dto, publicKey: key)
    request.httpBody = encrypted
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let string = String(data: data, encoding: .utf8)!
    
    print("string", string)
    
    #expect(string.starts(with: "{"))
}

struct DifyParam<Input: Codable>: Codable {
    var kind: String
    var userId: String
    var inputs: Input
    var stream: Bool
}

struct Inputs: Codable {
    var goal: String
}
