//
//  ViewController.swift
//  wordle
//
//  Created by Thomas Raybould on 3/29/22.
//

import UIKit

class ViewController: UICollectionViewController {
    
    let testData = Array(0...4)
    
    @IBOutlet var wordleCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        wordleCollectionView.delegate = self
        wordleCollectionView.dataSource = self
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    
        return testData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath as IndexPath) as! LetterCell
        
       
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }

}

