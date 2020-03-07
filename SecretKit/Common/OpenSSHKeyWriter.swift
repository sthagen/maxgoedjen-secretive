import Foundation
import CryptoKit

// For the moment, only supports ecdsa-sha2-nistp256 keys
public struct OpenSSHKeyWriter {

    public init() {
    }

    public func data<SecretType: Secret>(secret: SecretType) -> Data {
        lengthAndData(of: Constants.curveType.data(using: .utf8)!) +
            lengthAndData(of: Constants.curveIdentifier.data(using: .utf8)!) +
            lengthAndData(of: secret.publicKey)
    }

    public func openSSHString<SecretType: Secret>(secret: SecretType) -> String {
        "\(Constants.curveType) \(data(secret: secret).base64EncodedString())"
    }

    public func openSSHFingerprint<SecretType: Secret>(secret: SecretType) -> String {
        Insecure.MD5.hash(data: data(secret: secret))
            .compactMap { ("0" + String($0, radix: 16, uppercase: false)).suffix(2) }
            .joined(separator: ":")
    }

}

extension OpenSSHKeyWriter {

    public func lengthAndData(of data: Data) -> Data {
        let rawLength = UInt32(data.count)
        var endian = rawLength.bigEndian
        return Data(bytes: &endian, count: UInt32.bitWidth/8) + data
    }

    public func readData() {}
}

extension OpenSSHKeyWriter {

    public enum Constants {
        public static let curveIdentifier = "nistp256"
        public static let curveType = "ecdsa-sha2-nistp256"
    }

}
