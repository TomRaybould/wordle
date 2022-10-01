//
//  ViewController.swift
//  wordle
//
//  Created by Thomas Raybould on 3/29/22.
//

import UIKit

class ViewController: UIViewController {
    
    var wordleMainViewModel: WordleMainViewModel!
    
    var wordleCollectionViewCharArray:[WordleCollectionViewItem] = Array()
    var wordleKeyboardArray:[WordleKeyboardItem] = Array()
    
    @IBOutlet weak var wordleCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var wordleCollectionViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var wordleCollectionView: UICollectionView!
    @IBOutlet weak var wordleKeyboardCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordleMainViewModel = WordleMainViewModel(wordleMainViewDelegate: self, wordListProvider: WordList.instance)
        wordleMainViewModel.initGame()
        wordleCollectionView.dataSource = self
        wordleCollectionView.delegate = self
        
        wordleKeyboardCollectionView.dataSource = self
        wordleKeyboardCollectionView.delegate = self
        
        let screen = UIScreen.main.bounds
        let screenHeight = screen.size.height
        
        // 5/6 is the ratio of blocks in the grid
        let ratio = CGFloat(5.0/6.0)
        wordleCollectionViewHeight.constant = screenHeight/2
        wordleCollectionViewWidth.constant = (screenHeight/2) * ratio
        
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if(collectionView == wordleCollectionView){
            return wordleCollectionViewCharArray.count
        }else {
            return wordleKeyboardArray.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if(collectionView == wordleCollectionView){
            return dataBindWordleCell(collectionView, cellForItemAt: indexPath)
        }else{
            return dataBindKeyboardKey(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func dataBindWordleCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letterCell", for: indexPath as IndexPath) as! LetterCell
        
        let item = wordleCollectionViewCharArray[indexPath.row]
        
        let backgroundColor: UIColor? = {
            switch item.state {
            case WordleCollectionItemState.rightPosition:
                return UIColor(named: "CorrectPositionColor")
            case WordleCollectionItemState.wrongPosition:
                return UIColor(named: "WrongPositionColor")
            case WordleCollectionItemState.notInWord:
                return UIColor(named: "NotInWordColor")
            default:
                return UIColor.systemBackground
            }
        }()
        
        
        if(item.state == WordleCollectionItemState.empty || item.state == WordleCollectionItemState.newEntry){
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(named: "EmptyBorder")?.cgColor
        }else{
            cell.layer.borderWidth = 0
        }
        
        cell.backgroundColor = backgroundColor ?? UIColor.darkGray
        cell.letterValue.text = item.letterValue
        
        return cell
    }
    
    private func dataBindKeyboardKey(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keyboardKey", for: indexPath as IndexPath) as! KeyboardKey
        
        let item = wordleKeyboardArray[indexPath.row]
        cell.keyValue.text = item.keyValue
        
        if(item.state != WordleKeyboardItem.WordleKeyboardItemState.spacer){
            cell.layer.cornerRadius = 5.0
            
            let backgroundColor: UIColor? = {
                switch item.state {
                case WordleKeyboardItem.WordleKeyboardItemState.correctPosition:
                    return UIColor(named: "CorrectPositionColor")
                case WordleKeyboardItem.WordleKeyboardItemState.wrongPosition:
                    return UIColor(named: "WrongPositionColor")
                case WordleKeyboardItem.WordleKeyboardItemState.notInWord:
                    return UIColor(named: "NotInWordColor")
                default:
                    return UIColor.lightGray
                }
            }()
            
            cell.backgroundColor = backgroundColor ?? UIColor.darkGray
        }else{
            cell.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(collectionView == wordleKeyboardCollectionView){
            return getSizeCellForKeyboardCollectionView(_: collectionView, layout: collectionViewLayout, MinimumInteritemSpacingForSectionAt:indexPath)
        }
        
        
        let collectionWidth = min(collectionView.bounds.width, collectionView.bounds.height)
        
        let numberOfItemsPerRow:CGFloat = 5
        let spacingBetweenCells:CGFloat = 10
        
        let totalSpacing = ((numberOfItemsPerRow + 1) * spacingBetweenCells)
        
        let width = (collectionWidth - totalSpacing)/numberOfItemsPerRow
        return CGSize(width: width, height: width)
        
    }
    
    func getSizeCellForKeyboardCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, MinimumInteritemSpacingForSectionAt indexPath: IndexPath) -> CGSize {
        
        let collectionWidth = self.wordleKeyboardCollectionView.bounds.width
        
        let numberOfItemsPerRow:CGFloat = 10
        let spacingBetweenCells:CGFloat = 4
        
        let totalSpacing = (9 * spacingBetweenCells)
        //width calculated for the top row of keys with no spacers
        let standardKeyWidth = (collectionWidth - totalSpacing)/numberOfItemsPerRow
        
        var itemWidth = standardKeyWidth
        let itemHeight = standardKeyWidth * 1.25
        
        if(wordleKeyboardArray[indexPath.row].state == WordleKeyboardItem.WordleKeyboardItemState.spacer){
            //spacer items on the side of the second row of keys
            let totalPadding = 10 * spacingBetweenCells
            let widthOfKeys = 9 * standardKeyWidth
            let spacerWidth = (collectionWidth - (totalPadding + widthOfKeys)) / 2
            
            itemWidth = spacerWidth
        }else if(wordleKeyboardArray[indexPath.row].state == WordleKeyboardItem.WordleKeyboardItemState.enter ||
                 wordleKeyboardArray[indexPath.row].state == WordleKeyboardItem.WordleKeyboardItemState.backspace){
            
            let totalPadding = 8 * spacingBetweenCells
            let widthOfKeys = 7 * standardKeyWidth
            let spacerWidth = (collectionWidth - (totalPadding + widthOfKeys)) / 2
            
            itemWidth = spacerWidth
        }
        
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView != wordleKeyboardCollectionView) {return}
        wordleMainViewModel.onKeyPressedEntered(index: indexPath.row)
    }
    
}


extension ViewController : WordleMainViewDelegate{
    
    func showError(errorString: String) {
        let alert = getAlert(title: nil, message: errorString)
        
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    func showFailureDialog(correctWord: String) {
        let message = "The correct word was: " + correctWord
        let alert = getAlert(title: "You Lost :(", message: message)
        
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) {_ in
            self.wordleMainViewModel.initGame()
        }
        
        alert.addAction(tryAgainAction)
        
        self.present(alert, animated: true)
    }
    
    func showSuccessDialog() {
        let alert = getAlert(title: "You Won!!!", message: nil)
        
        let playAgainAction = UIAlertAction(title: "Play Again", style: .default) {_ in
            self.wordleMainViewModel.initGame()
        }
        
        alert.addAction(playAgainAction)
        
        self.present(alert, animated: true)
        
    }
    
    func getAlert(title: String?, message: String?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.systemBackground
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 16
        return alert
    }
    
    func updateCollectionView(collectionViewArray: [WordleCollectionViewItem]) {
        wordleCollectionViewCharArray = collectionViewArray
        wordleCollectionView.reloadData()
        wordleCollectionView.invalidateIntrinsicContentSize()
        wordleCollectionView.setNeedsLayout()
        wordleCollectionView.layoutIfNeeded()
    }
    
    func updateKeyboardKeys(keyboardKeys: [WordleKeyboardItem]) {
        wordleKeyboardArray = keyboardKeys
        wordleKeyboardCollectionView.reloadData()
        wordleCollectionView.invalidateIntrinsicContentSize()
        wordleCollectionView.setNeedsLayout()
        wordleCollectionView.layoutIfNeeded()
    }
    
    
    func displayTargetWord(targetWord: String) {
        print(targetWord)
    }
    
}
