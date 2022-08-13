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
    func updateKeyboardKey(keyboardKeys: [WordleKeyboardItem])
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
    private var keyboardKeysArray:[WordleKeyboardItem] = Array()
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
    
        initKeyboard()
        
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
                /*
                 remove the matched letter for the target array so we dont have multiple yellow tiles if the letter appear twice in the guess word
                 but once in the target word for example: target = SANDY guess = AMISS, only the first "S" should be in the wrong position
                 */
                let indexInTarget = targetStringArray.firstIndex(of: guessedChar)
                if let safeIndex = indexInTarget{
                    targetStringArray.remove(at: safeIndex)
                }
                
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
    

    
    private func updateKeyboardView(){
        self.wordleMainViewDelegate?.updateCollectionView(collectionViewArray: flattenD2Array)
    }
    
    func initKeyboard(){
        
        keyboardKeysArray = Array()
        
        //line one
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "Q", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "W", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "E", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "R", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "T", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "Y", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "U", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "I", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "O", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "P", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        
        //line two
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "A", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "S", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "D", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "F", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "G", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "H", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "J", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "K", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "L", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        
        //line three
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "Z", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "X", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "C", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "V", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "B", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "N", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(letterValue: "M", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        
    }
    
}
