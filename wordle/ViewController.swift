//
//  ViewController.swift
//  wordle
//
//  Created by Thomas Raybould on 3/29/22.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    
    let testData = Array(0...4)
    
    @IBOutlet weak var wordleCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        wordleCollectionView.dataSource = self
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return testData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "letterCell", for: indexPath as IndexPath) as! LetterCell
        
        
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
}

