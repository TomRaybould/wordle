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
    func updateKeyboardKeys(keyboardKeys: [WordleKeyboardItem])
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
    private var letterCount = 0

    
    init(wordleMainViewDelegate: WordleMainViewDelegate, wordListProvider: WordListProvider){
        self.wordListProvider = wordListProvider
        self.wordleMainViewDelegate = wordleMainViewDelegate
    }    

    func initGame(){
        wordsEnteredCount = 0
        letterCount = 0
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
    
    func onKeyPressedEntered(index: Int){
        let key = keyboardKeysArray[index]
        
        if(key.state == WordleKeyboardItem.WordleKeyboardItemState.backspace){
            onDeletePressed()
            return
        }else if(key.state == WordleKeyboardItem.WordleKeyboardItemState.enter){
            onEnterPressed()
            return
        }
        
        if(key.keyValue == nil || key.keyValue?.isEmpty == true || letterCount >= 5){ return }
        
        collectionViewItemArray[wordsEnteredCount][letterCount] = WordleCollectionViewItem.getLetterItem(letterValue: key.keyValue ?? "", state: WordleCollectionItemState.notInWord)
        
        updateWordleCollectionViewData()
        
        letterCount += 1
        
    }
    
    private func onDeletePressed(){
        if(letterCount <= 0){return}
        
        letterCount -= 1
        
        collectionViewItemArray[wordsEnteredCount][letterCount] = WordleCollectionViewItem.emptyLetterItem()
        updateWordleCollectionViewData()
    }
    
    private func onEnterPressed(){
        var newWord = ""
        for item in collectionViewItemArray[wordsEnteredCount] {
            if(item.state == WordleCollectionItemState.notInWord){
                newWord += item.letterValue ?? ""
            }
        }
        print(newWord)
        onWordEntered(newWord: newWord)
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
        wordsEnteredCount += 1
        letterCount = 0
        updateWordleCollectionViewData()
    }
    
    private func updateWordleCollectionViewData(){
        let flattenD2Array = collectionViewItemArray.flatMap({$0})
        self.wordleMainViewDelegate?.updateCollectionView(collectionViewArray: flattenD2Array)
    }

    
    private func updateKeyboardView(){
        self.wordleMainViewDelegate?.updateKeyboardKeys(keyboardKeys: keyboardKeysArray)
    }
    
    func initKeyboard(){
        
        keyboardKeysArray = Array()
        
        //line one
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Q", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "W", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "E", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "R", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "T", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Y", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "U", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "I", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "O", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "P", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        
        //line two
        keyboardKeysArray.append(WordleKeyboardItem.createSpacer())
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "A", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "S", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "D", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "F", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "G", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "H", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "J", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "K", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "L", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createSpacer())
        
        //line three
        keyboardKeysArray.append(WordleKeyboardItem.createEnterKey())
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Z", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "X", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "C", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "V", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "B", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "N", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "M", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))
        keyboardKeysArray.append(WordleKeyboardItem.createBackspaceKey())
        
        wordleMainViewDelegate.updateKeyboardKeys(keyboardKeys: keyboardKeysArray)
    }
    
}
