[![Build Status](https://travis-ci.org/voluntadpear/ReSwiftUndo.svg?branch=master&style=flat-square)](https://travis-ci.org/voluntadpear/ReSwiftUndo)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/voluntadpear/ReSwiftUndo/blob/master/LICENSE)

# ReSwiftUndo
Swift implementation of [redux-undo](https://github.com/omnidan/redux-undo) for Swift to use with [ReSwift](https://github.com/ReSwift/ReSwift) 4.0

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
let appReducer = undoable(reducer: reducer)

var store = Store<UndoableState<State>>(reducer: appReducer, state: nil)
```

If you only need a substate of your app to be undoable you can do something like this:
```swift
func appReducer(action: Action, state: State?) -> State {
    let folderUndoableReducer = undoable(reducer: foldersReducer, filter: filterCondition)
    return State(
            authenticationState: authenticationReducer(action: action, state: state?.authenticationState),
            commonState: commonReducer(action: action, state: state?.commonState),
            foldersState: folderUndoableReducer(action, state?.foldersState)
        )
}
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

### Filtering actions
Notice that only actions resulting in a new state are recorded. But if you want to discard some actions in the undo/redo history, or to only record history if a certain part of the state is changed you can
add a `filter` function to `undoable`. 

If you want to create your own filter, pass in a function or closure with the parameters of type 
`(Action, T, UndoableState<T>)` where you receive the action dispatched, the new currentState and the previous history. For example:

```swift
let filterCondition: UndoableFilter<FoldersState> = { (_, new, previous) in
            let previousPresent = previous.present
            let sameFolder = previousPresent.folder?.itemId == new.folder?.itemId
            return !sameFolder
        }
        
let folderUndoableReducer: (Action, UndoableState<FoldersState>?) -> UndoableState<FoldersState> = 
undoable(reducer: foldersReducer, filter: filterCondition)
```
## Install

### CocoaPods

Add to your `Podfile`:
```
pod 'ReSwiftUndo'
```

Run `pod install`
