
import Graphiti
import NIO

enum Episode : String, Codable {
    case newHope = "NEWHOPE"
    case empire = "EMPIRE"
    case jedi = "JEDI"
}

protocol SearchResult {}

protocol Character : Codable {
    var id: String { get }
    var name: String { get }
    var friends: [String] { get }
    var appearsIn: [Episode] { get }
}

struct Planet : Codable, SearchResult {
    let id: String
    let name: String
    let diameter: Int
    let rotationPeriod: Int
    let orbitalPeriod: Int
    var residents: [Human]
}

struct Human : Character, SearchResult {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let homePlanet: Planet
}

struct Droid : Character, SearchResult {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let primaryFunction: String
}

final class StarWarsStore {
    lazy var tatooine = Planet(
        id:"10001",
        name: "Tatooine",
        diameter: 10465,
        rotationPeriod: 23,
        orbitalPeriod: 304,
        residents: []
    )

    lazy var alderaan = Planet(
        id: "10002",
        name: "Alderaan",
        diameter: 12500,
        rotationPeriod: 24,
        orbitalPeriod: 364,
        residents: []
    )

    lazy var planetData: [String: Planet] = [
        "10001": tatooine,
        "10002": alderaan,
    ]

    lazy var luke = Human(
        id: "1000",
        name: "Luke Skywalker",
        friends: ["1002", "1003", "2000", "2001"],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )

    lazy var vader = Human(
        id: "1001",
        name: "Darth Vader",
        friends: [ "1004" ],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )

    lazy var han = Human(
        id: "1002",
        name: "Han Solo",
        friends: ["1000", "1003", "2001"],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )

    lazy var leia = Human(
        id: "1003",
        name: "Leia Organa",
        friends: ["1000", "1002", "2000", "2001"],
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )

    lazy var tarkin = Human(
        id: "1004",
        name: "Wilhuff Tarkin",
        friends: ["1001"],
        appearsIn: [.newHope],
        homePlanet: alderaan
    )

    lazy var humanData: [String: Human] = [
        "1000": luke,
        "1001": vader,
        "1002": han,
        "1003": leia,
        "1004": tarkin,
    ]

    lazy var c3po = Droid(
        id: "2000",
        name: "C-3PO",
        friends: ["1000", "1002", "1003", "2001"],
        appearsIn: [.newHope, .empire, .jedi],
        primaryFunction: "Protocol"
    )

    lazy var r2d2 = Droid(
        id: "2001",
        name: "R2-D2",
        friends: [ "1000", "1002", "1003" ],
        appearsIn: [.newHope, .empire, .jedi],
        primaryFunction: "Astromech"
    )

    lazy var droidData: [String: Droid] = [
        "2000": c3po,
        "2001": r2d2,
    ]

    /**
     * Helper function to get a character by ID.
     */
    func getCharacter(id: String) -> Character? {
        humanData[id] ?? droidData[id]
    }

    /**
     * Allows us to query for a character"s friends.
     */
    func getFriends(of character: Character) -> [Character] {
        character.friends.compactMap { id in
            getCharacter(id: id)
        }
    }

    /**
     * Allows us to fetch the undisputed hero of the Star Wars trilogy, R2-D2.
     */
    func getHero(of episode: Episode?) -> Character {
        if episode == .empire {
            // Luke is the hero of Episode V.
            return luke
        }
        // R2-D2 is the hero otherwise.
        return r2d2
    }

    /**
     * Allows us to query for the human with the given id.
     */
    func getHuman(id: String) -> Human? {
        humanData[id]
    }

    /**
     * Allows us to query for the droid with the given id.
     */
    func getDroid(id: String) -> Droid? {
        droidData[id]
    }

    /**
     * Allows us to get the secret backstory, or not.
     */
    func getSecretBackStory() throws -> String? {
        struct Secret : Error, CustomStringConvertible {
            let description: String
        }

        throw Secret(description: "secretBackstory is secret.")
    }

    /**
     * Allows us to query for a Planet.
     */
    func getPlanets(query: String) -> [Planet] {
        planetData
            .sorted(by: { $0.key < $1.key })
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    /**
     * Allows us to query for a Human.
     */
    func getHumans(query: String) -> [Human] {
        humanData
            .sorted(by: { $0.key < $1.key })
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    /**
     * Allows us to query for a Droid.
     */
    func getDroids(query: String) -> [Droid] {
        droidData
            .sorted(by: { $0.key < $1.key })
            .map({ $1 })
            .filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    /**
     * Allows us to query for either a Human, Droid, or Planet.
     */
    func search(query: String) -> [SearchResult] {
        return getPlanets(query: query) + getHumans(query: query) + getDroids(query: query)
    }
}

// secretBackstory is a property that doesn't exist in our original entity,
// but we'd like to expose it to Graphiti.
extension Character {
    var secretBackstory: String? {
        return nil
    }
}

// In aligment with our guidelines we have to define the keys for protocols
// in a global enum, because we can't adopt FieldKeyProvider in protocol
// extensions. The role of FieldKeyProvider will become clearer in the
// next extension.
enum CharacterFieldKeys : String {
    case id
    case name
    case friends
    case appearsIn
    case secretBackstory
}

// FieldKeyProvider is a protocol that allows us to define the keys which
// will be used to map properties and functions to GraphQL fields.
extension Planet : FieldKeyProvider {
    typealias FieldKey = FieldKeys

    enum FieldKeys : String {
        case id
        case name
        case diameter
        case rotationPeriod
        case orbitalPeriod
        case residents
    }
}

extension Human : FieldKeyProvider {
    typealias FieldKey = FieldKeys

    enum FieldKeys : String {
        case id
        case name
        case appearsIn
        case homePlanet
        case friends
        case secretBackstory
        case greeting
        case username
    }

    struct GreetingArguments : Codable {
        let username: String
    }

    func getFriends(store: StarWarsStore, arguments: NoArguments) -> [Character] {
        store.getFriends(of: self)
    }

    // Resolve functions can throw.
    func getSecretBackstory(store: StarWarsStore, arguments: NoArguments) throws -> String? {
        try store.getSecretBackStory()
    }

    func getGreeting(store: StarWarsStore, arguments: GreetingArguments) -> String {
        return "Hi, \(arguments.username)! I'm \(name)"
    }
}

extension Droid : FieldKeyProvider {
    typealias FieldKey = FieldKeys

    enum FieldKeys : String {
        case id
        case name
        case appearsIn
        case primaryFunction
        case friends
        case secretBackstory
    }

    func getFriends(store: StarWarsStore, arguments: NoArguments) -> [Character] {
        store.getFriends(of: self)
    }

    func getSecretBackstory(store: StarWarsStore, arguments: NoArguments) throws -> String? {
        try store.getSecretBackStory()
    }
}

struct StarWarsAPI : FieldKeyProvider {
    typealias FieldKey = FieldKeys

    enum FieldKeys : String {
        case id
        case episode
        case hero
        case human
        case droid
        case search
        case query
    }

    // Here we are defining the arguments for the getHero function.
    // Arguments need to adopt the Codable protocol.
    struct HeroArguments : Codable {
        let episode: Episode?
    }

    // Here we're simplin defining `HeroArguments` as the arguments for the
    // getHero function.
    func getHero(store: StarWarsStore, arguments: HeroArguments) -> Character {
        store.getHero(of: arguments.episode)
    }

    struct HumanArguments : Codable {
        let id: String
    }

    func getHuman(store: StarWarsStore, arguments: HumanArguments) -> Human? {
        store.getHuman(id: arguments.id)
    }

    struct DroidArguments : Codable {
        let id: String
    }

    func getDroid(store: StarWarsStore, arguments: DroidArguments) -> Droid? {
        store.getDroid(id: arguments.id)
    }

    struct SearchArguments : Codable {
        let query: String
    }

    func search(store: StarWarsStore, arguments: SearchArguments) -> [SearchResult] {
        store.search(query: arguments.query)
    }
}

let starWarsSchema = Schema<StarWarsAPI, StarWarsStore>([
    Enum(Episode.self, [
        Value(.newHope),

        Value(.empire),

        Value(.jedi),
    ]),

    Interface(Character.self, fieldKeys: CharacterFieldKeys.self, [
        Field(.id, at: \.id),

        Field(.name, at: \.name),

        Field(.friends, at: \.friends, overridingType: [TypeReference<Character>].self),

        Field(.appearsIn, at: \.appearsIn),

        Field(.secretBackstory, at: \.secretBackstory),
    ]),

    Type(Planet.self, fields: [
        Field(.id, at: \.id),
        Field(.name, at: \.name),
        Field(.diameter, at: \.diameter),
        Field(.rotationPeriod, at: \.rotationPeriod),
        Field(.orbitalPeriod, at: \.orbitalPeriod),
        Field(.residents, at: \.residents, overridingType: [TypeReference<Human>].self),
    ]),


    Type(Human.self, interfaces: Character.self, fields: [
        Field(.id, at: \.id),
        Field(.name, at: \.name),
        Field(.appearsIn, at: \.appearsIn),
        Field(.homePlanet, at: \.homePlanet),

        Field(.friends, at: Human.getFriends),

        Field(.secretBackstory, at: Human.getSecretBackstory),

        Field(.greeting, at: Human.getGreeting)
            .argument(.username, at: \.username),
    ]),

    Type(Droid.self, interfaces: Character.self, fields: [
        Field(.id, at: \.id),
        Field(.name, at: \.name),
        Field(.appearsIn, at: \.appearsIn),
        Field(.primaryFunction, at: \.primaryFunction),

        Field(.friends, at: Droid.getFriends),

        Field(.secretBackstory, at: Droid.getSecretBackstory),
    ]),

    Union(SearchResult.self, members: Planet.self, Human.self, Droid.self),

    Query([
        Field(.hero, at: StarWarsAPI.getHero)
            .argument(.episode, at: \.episode),

        Field(.human, at: StarWarsAPI.getHuman)
            .argument(.id, at: \.id),

        Field(.droid, at: StarWarsAPI.getDroid)
            .argument(.id, at: \.id),

        Field(.search, at: StarWarsAPI.search)
            .argument(.query, at: \.query, defaultValue: "R2-D2"),
    ]),

    Types(Human.self, Droid.self),
])

let query = """
{
    search(query: "R2") {
        __typename
        ... on Planet {
            name
        }
        ... on Human {
            name
        }
        ... on Droid {
            name
        }
    }
}
"""

let eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1)
print(try starWarsSchema.execute(request: query, root: StarWarsAPI(), context: StarWarsStore(), eventLoopGroup: eventLoop).wait())
