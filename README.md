[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/voluntadpear/ReSwiftUndo/blob/master/LICENSE)

# ReSwiftUndo
Swift implementation of [redux-undo](https://github.com/omnidan/redux-undo) for Swift to use with [ReSwift](https://github.com/ReSwift/ReSwift)

***Work in progress***

## Use

Suppose the state of your app is like this:
```swift
struct State: StateType, Equatable {
    var counter: Int = 0

    static func ==(lhr: State, rhr: State) -> Bool {
        return lhr.counter == rhr.counter
    }
}
```

**Notice:** it's important that your State conforms to the Equatable protocol.

And your reducer looks like this:
```swift
func reducer(action: Action, state: State?) -> State {
    var state = state ?? initialState()
    switch action {
    case _ as Increase:
        state.counter = state.counter + 1
    case _ as Decrease:
        state.counter = state.counter - 1
    default:
        break
    }
    return state
}

struct AppReducer: Reducer {
  func handleAction(action: Action, state: State?) -> State {
        return reducer(action, state)
    }
}
```
With ReSwiftUndo you can trigger actions that lets you go back to your previous state and back to the recent one.

Wrapping your state with `undoable` makes the state look like this:

```swift
public struct UndoableState<T>: StateType {
    public var past: [T]
    public var present: T
    public var future: [T]
}
```
Now you can get the current state like this: `state.present`

```swift
struct AppReducer: Reducer {
    func handleAction(action: Action, state: UndoableState<State>?) -> UndoableState<State> {
        return undoable(reducer: reducer)(action, state)
    }
}

var store = Store<UndoableState<State>>(reducer: AppReducer(), state: nil)
```

You can now trigger the `Undo` and `Redo` actions and do things like these:

```swift
print(store.state.present.counter) // 0
store.dispatch(Increase())
print(store.state.present.counter) // 1
print(store.state.past[0].counter) // 0
store.dispatch(Undo())
print(store.state.present.counter) // 0
print(store.state.future[0].counter) // 1
store.dispatch(Redo())
print(store.state.present.counter) // 1
```

