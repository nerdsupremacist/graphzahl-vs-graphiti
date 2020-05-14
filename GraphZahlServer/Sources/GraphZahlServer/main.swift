
import GraphZahl

enum Episode : String, CaseIterable, GraphQLEnum {
    case newHope
    case empire
    case jedi
}

class Character: GraphQLObject {
    let id: String
    let name: String
    var friends: [Character] = []
    let appearsIn: [Episode]

    func secretBackstory() throws -> String? {
        struct Secret : Error, CustomStringConvertible {
            let description: String
        }

        throw Secret(description: "secretBackstory is secret.")
    }

    internal init(id: String, name: String, appearsIn: [Episode]) {
        self.id = id
        self.name = name
        self.appearsIn = appearsIn
    }
}

class Planet : GraphQLObject {
    let id: String
    let name: String
    let diameter: Int
    let rotationPeriod: Int
    let orbitalPeriod: Int
    var residents: [Human]

    internal init(id: String, name: String, diameter: Int, rotationPeriod: Int, orbitalPeriod: Int, residents: [Human]) {
        self.id = id
        self.name = name
        self.diameter = diameter
        self.rotationPeriod = rotationPeriod
        self.orbitalPeriod = orbitalPeriod
        self.residents = residents
    }
}

class Human : Character {
    let homePlanet: Planet

    internal init(id: String, name: String, appearsIn: [Episode], homePlanet: Planet) {
        self.homePlanet = homePlanet
        super.init(id: id, name: name, appearsIn: appearsIn)
    }

    func greeting(username: String) -> String {
        return "Hi, \(username)! I'm \(name)"
    }
}

class Droid : Character {
    let primaryFunction: String

    internal init(id: String, name: String, friends: [String], appearsIn: [Episode], primaryFunction: String) {
        self.primaryFunction = primaryFunction
        super.init(id: id, name: name, appearsIn: appearsIn)
    }
}

enum SearchResult: GraphQLUnion {
    case human(Human)
    case droid(Droid)
    case planet(Planet)
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

    lazy var planets: [Planet] = [tatooine, alderaan]

    lazy var luke = Human(
        id: "1000",
        name: "Luke Skywalker",
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )

    lazy var vader = Human(
        id: "1001",
        name: "Darth Vader",
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: tatooine
    )

    lazy var han = Human(
        id: "1002",
        name: "Han Solo",
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )

    lazy var leia = Human(
        id: "1003",
        name: "Leia Organa",
        appearsIn: [.newHope, .empire, .jedi],
        homePlanet: alderaan
    )

    lazy var tarkin = Human(
        id: "1004",
        name: "Wilhuff Tarkin",
        appearsIn: [.newHope],
        homePlanet: alderaan
    )

    lazy var humans: [Human] = [luke, vader, han, leia, tarkin]

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

    lazy var droids: [Droid] = [c3po, r2d2]

    init() {
        luke.friends = [han, leia, c3po, r2d2]
        vader.friends = [tarkin]
        han.friends = [luke, leia, r2d2]
        leia.friends = [luke, han, c3po, r2d2]
        tarkin.friends = [vader]
        c3po.friends = [luke, han, leia, r2d2]
        r2d2.friends = [luke, han, leia]

        tatooine.residents = [luke, vader]
        alderaan.residents = [han, leia, tarkin]
    }

    func getPlanets(query: String) -> [Planet] {
        planets.filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    func getHumans(query: String) -> [Human] {
        humans.filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    func getDroids(query: String) -> [Droid] {
        droids.filter({ $0.name.lowercased().contains(query.lowercased()) })
    }

    func search(query: String) -> [SearchResult] {
        return getPlanets(query: query).map(SearchResult.planet) +
            getHumans(query: query).map(SearchResult.human) +
            getDroids(query: query).map(SearchResult.droid)
    }
}

enum API: GraphQLSchema {
    typealias ViewerContext = StarWarsStore

    class Query: QueryType {
        let store: StarWarsStore

        func hero(episode: Episode?) -> Character {
            switch episode {
            case .some(.empire):
                return store.luke
            default:
                return store.r2d2
            }
        }

        func human(id: String) -> Human? {
            return store.humans.first { $0.id == id }
        }

        func droid(id: String) -> Droid? {
            return store.droids.first { $0.id == id }
        }

        func search(query: String) -> [SearchResult] {
            return store.search(query: query)
        }

        required init(viewerContext store: StarWarsStore) {
            self.store = store
        }
    }

}

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

print(try API.perform(request: query, viewerContext: StarWarsStore()).wait())
