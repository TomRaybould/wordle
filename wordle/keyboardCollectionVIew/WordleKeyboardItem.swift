//
//  WordleKeyboardItem.swift
//  wordle
//
//  Created by Thomas Raybould on 8/13/22.
//

import Foundation

class WordleKeyboardItem {
    
    let keyValue: String?
    let state: WordleKeyboardItemState
    
    private init(keyValue: String, state: WordleKeyboardItemState){
        self.keyValue = keyValue
        self.state = state
    }
    
    static func createKeyboardItem(keyValue: String, state: WordleKeyboardItemState) -> WordleKeyboardItem{
        return WordleKeyboardItem(keyValue: keyValue, state: state)
    }
    
    //spacer takes up half the width of a normal key
    static func createSpacer() -> WordleKeyboardItem{
        return createKeyboardItem(keyValue: "", state: WordleKeyboardItemState.spacer)
    }
    
    //spacer takes up half the width of a normal key
    static func createBackspaceKey() -> WordleKeyboardItem{
        return createKeyboardItem(keyValue: "🔙", state: WordleKeyboardItemState.backspace)
    }
    
    //spacer takes up half the width of a normal key
    static func createEnterKey() -> WordleKeyboardItem{
        return createKeyboardItem(keyValue: "✔️", state: WordleKeyboardItemState.enter)
    }

    enum WordleKeyboardItemState{
        case unusedLetter
        case wrongPosition
        case notInWord
        case correctPosition
        case spacer
        case backspace
        case enter
    }

}
