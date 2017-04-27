//
//  ReSwiftUndoTests.swift
//  ReSwiftUndoTests
//
//  Created by Guillermo Peralta Scura on 8/4/17.
//  Copyright © 2017 voluntadpear. All rights reserved.
//

import Quick
import Nimble
import ReSwift
import ReSwiftUndo

struct State: StateType, Equatable {
    var counter: Int = 0
    var secondaryCounter: Int = 0

    static func ==(lhr: State, rhr: State) -> Bool {
        return lhr.counter == rhr.counter && lhr.secondaryCounter == rhr.secondaryCounter
    }
}

struct Increase: Action {}
struct Decrease: Action {}
struct IncreaseSecondary: Action {}
struct DecreaseSecondary: Action {}
struct NullAction: Action {}

func reducer(action: Action, state: State?) -> State {
    var state = state ?? initialState()
    switch action {
    case _ as Increase:
        state.counter += 1
    case _ as Decrease:
        state.counter -= 1
    case _ as IncreaseSecondary:
        state.secondaryCounter += 1
    case _ as DecreaseSecondary:
        state.secondaryCounter -= 1
    default:
        break
    }
    return state
}

let justMainActions: UndoableFilter<State> = { (action, _, _) in
    switch action {
    case _ as IncreaseSecondary:
        return false
    default:
        break
    }
    return true
}

let appReducer = undoable(reducer: reducer, filter: justMainActions)

func initialState() -> State {
    return State(counter: 0, secondaryCounter: 0)
}

var store: Store<UndoableState<State>>!

class ReSwiftUndoTests: QuickSpec {
    override func spec() {
        beforeEach {
            store = Store<UndoableState<State>>(reducer: appReducer, state: nil)

        }
        describe("ReSwiftUndo") {
            it("goes to the past") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))

                store.dispatch(Undo())

                expect(store.state.present.counter).to(equal(0))
                expect(store.state.past.count).to(equal(0))
            }
            it("goes to the future") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))
                expect(store.state.future.count).to(equal(0))

                store.dispatch(Undo())

                expect(store.state.present.counter).to(equal(0))
                expect(store.state.past.count).to(equal(0))
                expect(store.state.future[0].counter).to(equal(1))

                store.dispatch(Redo())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))
                expect(store.state.future.count).to(equal(0))
                expect(store.state.past.count).to(equal(1))
            }
            it("actions that do not affect state shouldn't be considered") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))

                store.dispatch(NullAction())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past.count).to(equal(1))
            }
            it("actions that do affect state should be considered") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))

                store.dispatch(Decrease())
                
                expect(store.state.present.counter).to(equal(0))
                expect(store.state.past.count).to(equal(2))
            }
            it("breaks old future") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.past[0].counter).to(equal(0))
                expect(store.state.future.count).to(equal(0))

                store.dispatch(Undo())

                expect(store.state.present.counter).to(equal(0))
                expect(store.state.past.count).to(equal(0))
                expect(store.state.future[0].counter).to(equal(1))

                store.dispatch(Decrease())


                expect(store.state.present.counter).to(equal(-1))
                expect(store.state.past[0].counter).to(equal(0))

                store.dispatch(Redo())

                expect(store.state.present.counter).to(equal(-1))
                expect(store.state.past[0].counter).to(equal(0))
                expect(store.state.future.count).to(equal(0))
                expect(store.state.past.count).to(equal(1))
            }
            it("filters some actions") {
                expect(store.state.present.counter).to(equal(0))

                store.dispatch(Increase())
                store.dispatch(IncreaseSecondary())
                store.dispatch(IncreaseSecondary())

                expect(store.state.present.counter).to(equal(1))
                expect(store.state.present.secondaryCounter).to(equal(2))
                expect(store.state.past[0].counter).to(equal(0))
                expect(store.state.past[0].secondaryCounter).to(equal(0))
                expect(store.state.future.count).to(equal(0))
                expect(store.state.past.count).to(equal(1))

                store.dispatch(Undo())
                store.dispatch(Decrease())
                store.dispatch(DecreaseSecondary())
                store.dispatch(DecreaseSecondary())

                expect(store.state.present.counter).to(equal(-1))
                expect(store.state.present.secondaryCounter).to(equal(-2))
                expect(store.state.past[0].counter).to(equal(-1))
                expect(store.state.past[0].secondaryCounter).to(equal(-1))
                expect(store.state.past[1].counter).to(equal(-1))
                expect(store.state.past[1].secondaryCounter).to(equal(0))
                expect(store.state.past[2].counter).to(equal(0))
                expect(store.state.past[2].secondaryCounter).to(equal(0))
            }
        }
    }
}
