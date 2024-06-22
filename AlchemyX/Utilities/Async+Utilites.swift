#if canImport(Combine)

import Combine

extension Publisher where Failure == Never {
    var stream: AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = sink { continuation.yield($0) }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

#endif
