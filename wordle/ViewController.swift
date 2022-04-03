//
//  ViewController.swift
//  wordle
//
//  Created by Thomas Raybould on 3/29/22.
//

import UIKit

class ViewController: UIViewController {
    
    var testData:[Character] = Array()
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var wordleCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordleCollectionView.dataSource = self
        wordleCollectionView.delegate = self
        textInput.delegate = self
        textInput.placeholder = "Guess a word..."
    }
 
    func updateData(newString: String){
        for char in newString{
            testData.append(char)
        }
        wordleCollectionView.reloadData()
    }
}

extension ViewController :UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return testData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letterCell", for: indexPath as IndexPath) as! LetterCell
        
        cell.backgroundColor = UIColor.darkGray
        cell.letterValue.text = String(testData[indexPath.row])
        
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
            
        if let text = textField.text?.uppercased(), text.count == 5{
            print(text)
            updateData(newString: text)
            textField.text = ""
        }
        
        return false
    }
    

}
