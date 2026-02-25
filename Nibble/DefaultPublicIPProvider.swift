import Foundation

final class DefaultPublicIPProvider: PublicIPProviding {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPublicIP(completion: @escaping @Sendable (String?) -> Void) {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            completion(nil)
            return
        }

        session.dataTask(with: url) { data, _, error in
            guard error == nil, let data else {
                completion(nil)
                return
            }

            completion(Self.parsePublicIP(from: data))
        }.resume()
    }

    static func parsePublicIP(from data: Data) -> String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
            let ip = json["ip"]
        else {
            return nil
        }
        return ip
    }
}
