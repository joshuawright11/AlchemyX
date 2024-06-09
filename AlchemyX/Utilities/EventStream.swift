import Combine

final class EventStream {
    enum Event {
        case resourceChanged(any Resource.Type)
        case signin
        case signout
    }

    static let shared = EventStream()

    @Published private var event: Event? = nil

    @MainActor
    static func fire(_ event: Event) {
        shared.event = event
    }

    static func monitorAuth() -> AsyncStream<Void> {
        shared.$event
            .compactMap { event in
                switch event {
                case .signin:  return
                case .signout: return
                default:       return nil
                }
            }
            .stream
    }

    static func monitorResource(_ type: (some Resource).Type) -> AsyncStream<Void> {
        shared.$event
            .compactMap { event in
                switch event {
                case .resourceChanged(let resource) where resource == type:
                    return
                default:
                    return nil
                }
            }
            .stream
    }
}
