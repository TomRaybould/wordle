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
    
    private var wordleMainViewDelegate: WordleMainViewDelegate?
    private var targetWord = WordList.getWordList().randomElement()!.uppercased()
    private var collectionViewItemArray: [[WordleCollectionViewItem]] = Array()
    private var wordsEnteredCount = 0

    
    func setDelegate(wordleMainViewDelegate: WordleMainViewDelegate){
        self.wordleMainViewDelegate = wordleMainViewDelegate
        initGame()
    }

    func initGame(){
        wordsEnteredCount = 0
        targetWord = WordList.getWordList().randomElement()!.uppercased()
        
        //init with 30 empty cells 6 rows 5 cols
        collectionViewItemArray = (0...5).map ({row in
            (0...4).map({col in WordleCollectionViewItem.emptyLetterItem()})
        })
    
        self.wordleMainViewDelegate?.displayTargetWord(targetWord: targetWord)
        updateWordleCollectionViewData()
    }
    
    func onWordEntered(newWord: String?){
        if let text = newWord?.uppercased(), text.count == 5{
            addNewWordToList(newWord: text)
        }else{
            self.wordleMainViewDelegate?.showError(errorString: "Word must be 5 letters")
        }
    
    }
    
    private func addNewWordToList(newWord: String){
    
        if(!WordList.getWordList().contains(newWord.uppercased())){
            self.wordleMainViewDelegate?.showError(errorString: "Word not in list")
            return
        }
        
        var newWordLetterItemsArray: [WordleCollectionViewItem] = Array()
        
        for (index, char) in newWord.enumerated() {
            
            let state: WordleCollectionItemState
            if(char == targetWord[targetWord.index(targetWord.startIndex, offsetBy: index)]){
                state = WordleCollectionItemState.rightPosition
            }else if(targetWord.contains(char)){
                state = WordleCollectionItemState.wrongPosition
            } else {
                state = WordleCollectionItemState.notInWord
            }
            
            let item = WordleCollectionViewItem.getLetterItem(letterValue: String(char), state: state)
            newWordLetterItemsArray.append(item)
        }
        
        collectionViewItemArray[wordsEnteredCount] = newWordLetterItemsArray
        wordsEnteredCount+=1
        updateWordleCollectionViewData()
    }
    
    private func updateWordleCollectionViewData(){
        let flattenD2Array = collectionViewItemArray.flatMap({$0})
        self.wordleMainViewDelegate?.updateCollectionView(collectionViewArray: flattenD2Array)
    }
}
