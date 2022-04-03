//
//  WordleMainViewModel.swift
//  wordle
//
//  Created by Thomas Raybould on 4/3/22.
//

import Foundation

protocol WordleMainViewDelegate{
    func displayTargetWord(targetWord: String)
    func updateCollectionView(collectionViewArray: [WordleCollectionViewItem])
    func showError(errorString: String)
}

class WordleMainViewModel{
    
    var wordleMainViewDelegate: WordleMainViewDelegate?
    
    //todo: remove hardcoded target word
    let targetWord = "WORDS"
    var collectionViewCharArray: [WordleCollectionViewItem] = Array()
    
    func setDelegate(wordleMainViewDelegate: WordleMainViewDelegate){
        self.wordleMainViewDelegate = wordleMainViewDelegate
        self.wordleMainViewDelegate?.displayTargetWord(targetWord: targetWord)
    }

    func onWordEntered(newWord: String?){
        if let text = newWord?.uppercased(), text.count == 5{
            addNewWordToList(newWord: text)
        }else{
            self.wordleMainViewDelegate?.showError(errorString: "Word must be 5 letters")
        }
    
    }
    
    private func addNewWordToList(newWord: String){
        for (index, char) in newWord.enumerated() {
            
            let state: WordleCollectionItemState
            if(char == targetWord[targetWord.index(targetWord.startIndex, offsetBy: index)]){
                state = WordleCollectionItemState.rightPosition
            }else if(targetWord.contains(char)){
                state = WordleCollectionItemState.wrongPosition
            } else {
                state = WordleCollectionItemState.notInWord
            }
            
            let item = WordleCollectionViewItem(letterValue: String(char), state: state)
            collectionViewCharArray.append(item)
        }
    
        
        self.wordleMainViewDelegate?.updateCollectionView(collectionViewArray: collectionViewCharArray)
    }
    
}
