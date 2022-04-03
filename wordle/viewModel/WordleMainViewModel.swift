//
//  WordleMainViewModel.swift
//  wordle
//
//  Created by Thomas Raybould on 4/3/22.
//

import Foundation

protocol WordleMainViewDelegate{
    func displayTargetWord(targetWord: String)
    func updateCollectionView(collectionViewArray: [Character])
    func showError(errorString: String)
}

class WordleMainViewModel{
    
    var wordleMainViewDelegate: WordleMainViewDelegate?
    
    //todo: remove hardcoded target word
    let targetWord = "WORDS"
    var collectionViewCharArray: [Character] = Array()
    
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
        for char in newWord{
            collectionViewCharArray.append(char)
        }
        
        self.wordleMainViewDelegate?.updateCollectionView(collectionViewArray: collectionViewCharArray)
    }
    
}
