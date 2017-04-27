//
//  UndoReducer.swift
//  ReSwiftUndo
//
//  Created by Guillermo Peralta Scura on 8/4/17.
//  Copyright © 2017 voluntadpear. All rights reserved.
//

import Foundation
import ReSwift

public struct UndoableState<T>: StateType {
    public var past: [T]
    public var present: T
    public var future: [T]

    public init(past: [T], present: T, future: [T]) {
        self.past = past
        self.present = present
        self.future = future
    }
}

public typealias UndoableFilter<T> = (Action, T, UndoableState<T>) -> Bool

public func undoable<T: Equatable>(reducer: @escaping Reducer<T>,
                     filter: UndoableFilter<T>? = nil) -> Reducer<UndoableState<T>>   {
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
            if newPresent == state.present {
                //Don't handle this action
                return state
            }

            if(filter == nil || (filter != nil && filter!(action, newPresent, state))) {
                // If the action wasn't filtered, insert normally
                state.past = previousArray
                state.future = []
            } // else do nothing
            state.present = newPresent
        }
        return state
    }
}

struct DummyAction: Action {}
public struct Undo: Action { public init() {} }
public struct Redo: Action { public init() {} }
