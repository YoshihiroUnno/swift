// RUN: %target-swift-frontend -disable-availability-checking -parse-as-library %s -emit-sil -o /dev/null -verify
// RUN: %target-swift-frontend -disable-availability-checking -parse-as-library %s -emit-sil -o /dev/null -verify -strict-concurrency=targeted
// RUN: %target-swift-frontend -disable-availability-checking -parse-as-library %s -emit-sil -o /dev/null -verify -strict-concurrency=complete
// RUN: %target-swift-frontend -disable-availability-checking -parse-as-library %s -emit-sil -o /dev/null -verify -strict-concurrency=complete -enable-experimental-feature SendNonSendable

// REQUIRES: concurrency

@globalActor
actor Kat {
  static let shared = Kat()
}

@Kat
var poof: Int = 1337 // expected-note{{var declared here}}

@main struct Doggo {
  @Kat
  static func main() { // expected-error{{main() must be '@MainActor'}}
    // expected-error@+1{{global actor 'Kat'-isolated var 'poof' can not be referenced from the main actor}}
    print("Kat value: \(poof)")
  }
}

struct Bunny {
  // Bunnies are not @main, so they can have a "main" function that is on
  // another actor. It's not actually the main function, so it's fine.
  @Kat
  static func main() {
  }
}
