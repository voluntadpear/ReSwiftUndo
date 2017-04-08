//
//  UndoReducer.swift
//  ReSwiftUndo
//
//  Created by Guillermo Peralta Scura on 8/4/17.
//  Copyright © 2017 voluntadpear. All rights reserved.
//

import Foundation
import ReSwift

struct UndoableState<T> {
    var past: [T]
    var present: T
    var future: [T]
}

// We create a ReducerType typealias because as ReSwift 3.0.0 Reducer is not a function typealias yet
// that changes on ReSwift 4.0.0

public typealias ReducerType<ReducerStateType> =
    (_ action: Action, _ state: ReducerStateType?) -> ReducerStateType


func undoable<T: Equatable>(reducer: @escaping ReducerType<T>) -> (ReducerType<UndoableState<T>>)   {
    let initialState = UndoableState<T>(past: [], present: reducer(DummyAction(), nil), future: [])

    return { (action: Action, state: UndoableState<T>?) in
        var state = state ?? initialState
        switch action {
        case _ as Undo:
            if let previous = state.past.first {
                let previousArrays = Array(state.past.dropFirst())
                state.past = previousArrays
                let present = state.present
                state.present = previous
                state.future = [present] + state.future
            }
        case _ as Redo:
            if let next = state.future.first {
                let newFutureArray = Array(state.future.dropFirst())
                state.past = [state.present] + state.past
                state.present = next
                state.future = newFutureArray
            }

        default:
            let previousArray = [state.present] + state.past
            let newPresent = reducer(action, state.present)
            if newPresent != state.present {
                state.past = previousArray
                state.present = newPresent
                state.future = []
            }
        }
        return state
    }
}

struct DummyAction: Action {}
struct Undo: Action {}
struct Redo: Action {}
