//
//  EncryptedBody.swift
//  MyCrypto
//
//  Created by Kai Shao on 2024/11/8.
//

import Foundation

public struct EncryptedBody: Codable, Sendable {
    public let timestamp: TimeInterval
    public let jsonData: Data
    
    public init(timestamp: TimeInterval, jsonData: Data) {
        self.timestamp = timestamp
        self.jsonData = jsonData
    }
}
