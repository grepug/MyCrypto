# MyCrypto

## Overview

MyCrypto is a Swift package that provides utilities for encrypting and decrypting data using public and private keys. This package is useful for securely transmitting data over networks.

## Installation

To install MyCrypto, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/grepug/MyCrypto.git", branch: "main")
]
```

## Usage

### Encrypting Data

To encrypt data using a public key, you can use the `CryptoUtils.encrypt` method. Below is an example of how to use this method in a test:

```swift
import Foundation
import MyCrypto

let publicKeyPEM = """
-----BEGIN PUBLIC KEY-----
xxxxxx
-----END PUBLIC KEY-----
"""

```swift
// Create a dictionary with the data to be encrypted
let dtoo = ["name": "kai", "sirname": "shao"]

// Create an EncryptedBody object with the current timestamp and JSON-encoded data
let dto = EncryptedBody(
    timestamp: Date().timeIntervalSince1970,
    jsonData: try JSONEncoder().encode(dtoo)
)

// Encrypt the EncryptedBody object using the public key
let encrypted = try CryptoUtils.encrypt(
    object: dto, publicKeyPEM: publicKeyPEM)

// Create a URL request to the specified endpoint
var urlRequest = URLRequest(
    url: URL(string: "http://localhost:8081/v1/test")!)
urlRequest.httpMethod = "POST"

// Set the encrypted data as the HTTP body of the request
urlRequest.httpBody = encrypted.data(using: .utf8)

// Send the request and receive the response
let (data, _) = try await URLSession.shared.data(for: urlRequest)

// Decode the response data back into a dictionary
let dtooo = try JSONDecoder().decode([String: String].self, from: data)

// Verify that the original data matches the decoded response data
#expect(dtoo == dtooo)
```
```

In this example, we create an `EncryptedBody` object containing a timestamp and JSON-encoded data. We then encrypt this object using a public key and send it in an HTTP POST request. Finally, we decode the response and verify that it matches the original data.
