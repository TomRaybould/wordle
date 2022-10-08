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
    func updateCollectionIndex(index: Int, wordleCollectionViewItem: WordleCollectionViewItem)
    func updateCollectionRow(startIndex: Int, wordleCollectionViewItems: [WordleCollectionViewItem])
    func updateKeyboardKeys(keyboardKeys: [WordleKeyboardItem])
    func showError(errorString: String)
    func showSuccessDialog()
    func showFailureDialog(correctWord: String)
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
    private var isInputDisabled = false

    
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
    
    private func onWordEntered(newWord: String?){
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
        
        let index = getUiIndexForItem(offset: letterCount)
        
        collectionViewItemArray[wordsEnteredCount][letterCount] = WordleCollectionViewItem.getNewEntryItem(letterValue: key.keyValue!)
        
        wordleMainViewDelegate.updateCollectionIndex(index: index, wordleCollectionViewItem: WordleCollectionViewItem.getNewEntryItem(letterValue: key.keyValue!))
        
        letterCount += 1
        
    }
    
    private func onDeletePressed(){
        if(letterCount <= 0){return}
        
        letterCount -= 1
        
        let emptyLetter = WordleCollectionViewItem.emptyLetterItem()
        collectionViewItemArray[wordsEnteredCount][letterCount] = emptyLetter
        
        let index = getUiIndexForItem(offset: letterCount)
        
        self.wordleMainViewDelegate.updateCollectionIndex(index: index, wordleCollectionViewItem: emptyLetter)
    }
    
    private func onEnterPressed(){
        var newWord = ""
        for item in collectionViewItemArray[wordsEnteredCount] {
            if(item.state == WordleCollectionItemState.newEntry){
                newWord += item.letterValue ?? ""
            }
        }
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
        
        isInputDisabled = true
        
        //update UI
        collectionViewItemArray[wordsEnteredCount] = newWordLetterItemsArray
        addWordToUI(newWord: newWordLetterItemsArray)
    }
    
    func onWordAnimationFinished(){
        if(letterCount < 5) {return}
        
        //update colors on keyboard
        updateKeyboardKeyColors()
        
        //check for winner
        var isWinner = true
        
        //get last word
        let newWordLetterItemsArray = collectionViewItemArray[wordsEnteredCount]
    
        for letterItem in newWordLetterItemsArray{
            if(letterItem.state != .rightPosition){
                isWinner = false
                break
            }
        }
        
        if(isWinner){
            self.wordleMainViewDelegate.showSuccessDialog()
        }else if (wordsEnteredCount == 5){
            //user has entered 6 words, no more tries
            self.wordleMainViewDelegate.showFailureDialog(correctWord: self.targetWord)
        }else{
            //update counters
            wordsEnteredCount += 1
            letterCount = 0
            isInputDisabled = false
        }
        
    }
    
    //adds the word to the ui collectionView
    private func addWordToUI(newWord: [WordleCollectionViewItem]){
        let index = getUiIndexForItem(offset: 0)
        self.wordleMainViewDelegate.updateCollectionRow(startIndex: index, wordleCollectionViewItems: newWord)
    }
    
    private func getUiIndexForItem(offset: Int) -> Int{
        return (wordsEnteredCount * 5) + offset
    }
    
    
    //updating the colors of the keys to show what letters are used in the word, and what letters are in the rigth position.
    private func updateKeyboardKeyColors(){
        for wordleCellItem in collectionViewItemArray.flatMap({$0}){
            
            let index = getKeyIndex(target: wordleCellItem.letterValue!)
            
            if(wordleCellItem.state == WordleCollectionItemState.notInWord){
                
                let key = keyboardKeysArray[index]
                //check if this key is not also already used in the correct position
                if(key.state != .correctPosition){
                    keyboardKeysArray[index] = WordleKeyboardItem.createKeyboardItem(keyValue: key.keyValue ?? "", state: .notInWord)
                }
                
            } else if(wordleCellItem.state == .wrongPosition){
                
                let key = keyboardKeysArray[index]
                //check if this key is not also already used in the correct position
                if(key.state != .correctPosition){
                    keyboardKeysArray[index] = WordleKeyboardItem.createKeyboardItem(keyValue: key.keyValue ?? "", state: .wrongPosition)
                }
                
            } else if(wordleCellItem.state == .rightPosition){
                
                let keyValue = keyboardKeysArray[index].keyValue
                keyboardKeysArray[index] = WordleKeyboardItem.createKeyboardItem(keyValue: keyValue ?? "", state: .correctPosition)
                
            }

        }

        self.wordleMainViewDelegate?.updateKeyboardKeys(keyboardKeys: keyboardKeysArray)
    }
    
    //returns the index of the key with a value equal to the target
    private func getKeyIndex(target: String) -> Int{
        return keyboardKeysArray.firstIndex{$0.keyValue == target } ?? -1
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
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Q", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//0
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "W", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//1
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "E", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//2
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "R", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//3
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "T", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//4
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Y", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//5
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "U", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//6
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "I", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//7
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "O", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//8
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "P", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//9
        
        //line two
        keyboardKeysArray.append(WordleKeyboardItem.createSpacer())//10
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "A", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//11
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "S", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//12
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "D", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//13
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "F", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//14
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "G", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//15
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "H", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//16
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "J", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//17
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "K", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//18
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "L", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//19
        keyboardKeysArray.append(WordleKeyboardItem.createSpacer())//20
        
        //line three
        keyboardKeysArray.append(WordleKeyboardItem.createEnterKey())//21
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "Z", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//22
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "X", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//23
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "C", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//24
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "V", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//25
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "B", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//26
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "N", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//27
        keyboardKeysArray.append(WordleKeyboardItem.createKeyboardItem(keyValue: "M", state: WordleKeyboardItem.WordleKeyboardItemState.unusedLetter))//28
        keyboardKeysArray.append(WordleKeyboardItem.createBackspaceKey())//29
        
        wordleMainViewDelegate.updateKeyboardKeys(keyboardKeys: keyboardKeysArray)
    }
    
}
