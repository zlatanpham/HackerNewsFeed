import Foundation

struct AlgoliaSearchResponse: Codable {
    let hits: [AlgoliaHit]
    let nbHits: Int
    let page: Int
    let hitsPerPage: Int
}

struct AlgoliaHit: Codable {
    let objectID: String
    let title: String?
    let url: String?
    let author: String?
    let points: Int?
    let numComments: Int?
    let createdAtI: Int?

    enum CodingKeys: String, CodingKey {
        case objectID, title, url, author, points
        case numComments = "num_comments"
        case createdAtI = "created_at_i"
    }
}
