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

    enum WordleKeyboardItemState{
        case unusedLetter
        case wrongPosition
        case notInWord
        case correctPosition
    }

}
