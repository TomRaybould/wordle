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
    
    @IBOutlet weak var wordleCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var wordleCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordleMainViewModel = WordleMainViewModel(wordleMainViewDelegate: self, wordListProvider: WordList.instance)
        wordleMainViewModel.initGame()
        wordleCollectionView.dataSource = self
        wordleCollectionView.delegate = self
        textInput.delegate = self
        textInput.placeholder = "Guess a word..."
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = wordleCollectionView.collectionViewLayout.collectionViewContentSize.height
        wordleCollectionViewHeight.constant = height
        self.view.setNeedsLayout()
    }
    
    
 
}

extension ViewController :UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return wordleCollectionViewCharArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
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
        
        
        if(item.state == WordleCollectionItemState.empty){
            cell.layer.borderWidth = 3
            cell.layer.borderColor = UIColor(named: "EmptyBorder")?.cgColor
        }else{
            cell.layer.borderWidth = 0
        }
        
        cell.backgroundColor = backgroundColor ?? UIColor.darkGray
        cell.letterValue.text = item.letterValue
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItemsPerRow:CGFloat = 5
        let spacingBetweenCells:CGFloat = 8
                
        let totalSpacing = ((numberOfItemsPerRow + 1) * spacingBetweenCells)
                
        if let collection = self.wordleCollectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
    
}

extension ViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        wordleMainViewModel.onWordEntered(newWord: textField.text)
        textField.text = ""
        return false
    }
    
}

extension ViewController : WordleMainViewDelegate{
    
    func showError(errorString: String) {
        let alert = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 16
    
        self.present(alert, animated: true)
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    func updateCollectionView(collectionViewArray: [WordleCollectionViewItem]) {
        wordleCollectionViewCharArray = collectionViewArray
        wordleCollectionView.reloadData()
        wordleCollectionView.invalidateIntrinsicContentSize()
        wordleCollectionView.setNeedsLayout()
        wordleCollectionView.layoutIfNeeded()
    }
    
    func displayTargetWord(targetWord: String) {
        print(targetWord)
    }
    
}
