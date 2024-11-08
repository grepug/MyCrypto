import Foundation
import Testing

@testable import MyCrypto

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    let publicKeyPEM = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvkzNNmv8PC/hgsj4X3ey
        QKSPrVp7XaZU67J/yJlDA9qr45xj5TV67WcZJkli6hEyPu6k/pTxKu+GDRKjmAIr
        BznElmXb1cd7Z//Sm8U/lCwJI460aigksSfVBPEjpO0CAiDMBMW3r1Att+0NG81O
        1R9RTFCJCH1o3r+Aav5IJenYRWIVUKctXMu59N1qYV5heWs9mnwlpjhG/3uN6c8h
        IG5r0/Nue6LgDT0WFf5+D0odkrZ2pI+WcaYyVmqZHRxFS25yGRtXBn1aANcMkq//
        0lG7z0Fq86+yCYLEY9DPPkP15ea1PvhdL7MMyAPKjZJVksef04AYlYSffW86D5JL
        UwIDAQAB
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
