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

protocol WordListProvider {
    func getSolutionWordList() -> [String]
    func getValidGeussWordList() -> [String]
}

class WordleMainViewModel{
    
    private var wordleMainViewDelegate: WordleMainViewDelegate!
    private var wordListProvider: WordListProvider!
    private var targetWord: String = ""
    private var collectionViewItemArray: [[WordleCollectionViewItem]] = Array()
    private var wordsEnteredCount = 0

    
    init(wordleMainViewDelegate: WordleMainViewDelegate, wordListProvider: WordListProvider){
        self.wordListProvider = wordListProvider
        self.wordleMainViewDelegate = wordleMainViewDelegate
    }    

    func initGame(){
        wordsEnteredCount = 0
        targetWord = wordListProvider.getSolutionWordList().randomElement()!.uppercased()
        
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
        if(!wordListProvider.getValidGeussWordList().contains(newWord.uppercased())){
            self.wordleMainViewDelegate?.showError(errorString: "Word not in list")
            return
        }
        
        var targetStringArray: [String?] = Array(repeating: nil, count: 5)
        var newWordLetterItemsArray: [WordleCollectionViewItem] = Array(repeating: WordleCollectionViewItem.emptyLetterItem(), count: 5)
        
        for (index, char) in targetWord.enumerated() {
            targetStringArray[index] = String(char)
        }
    
        //filter out right position
        for (index, char) in newWord.enumerated() {
            let guessedChar = String(char)
            
            if(guessedChar == targetStringArray[index]){
                let item = WordleCollectionViewItem.getLetterItem(letterValue: guessedChar, state: WordleCollectionItemState.rightPosition)
                newWordLetterItemsArray[index] = item
                targetStringArray[index] = nil
            }
        }
        
        //check for wrongPosition else notInWord
        for (index, char) in newWord.enumerated() {
            if(newWordLetterItemsArray[index].state == WordleCollectionItemState.rightPosition){
                continue
            }
            let guessedChar = String(char)
            if(targetStringArray.contains(guessedChar)){
                let item = WordleCollectionViewItem.getLetterItem(letterValue: guessedChar, state: WordleCollectionItemState.wrongPosition)
                newWordLetterItemsArray[index] = item
            }else{
                let item = WordleCollectionViewItem.getLetterItem(letterValue: guessedChar, state: WordleCollectionItemState.notInWord)
                newWordLetterItemsArray[index] = item
            }
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
