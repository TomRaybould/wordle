//
//  wordleMainViewModelTests.swift
//  wordleTests
//
//  Created by Thomas Raybould on 4/10/22.
//

import XCTest
@testable import wordle

class wordleMainViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_given_the_solution_is_WATER_and_the_first_guessed_word_is_BETTY_then_the_first_T_should_have_a_state_of_rightPosition_and_the_second_T_should_have_a_state_of_notInWord() throws{
        
        let wordleMainViewDelegate = wordleMainViewModelTests.getWordleMainViewDelegate()
        let wordListProvider = wordleMainViewModelTests.getWordListProvider(validGeussWordList: ["BETTY"], solutionWordList: ["WATER"])
        
        let viewModel = wordleMainViewModelTests.getViewModel(wordleMainViewDelegate: wordleMainViewDelegate, wordListProvider: wordListProvider)
        viewModel.initGame()
        
        //simulate user guessing BETTY
        viewModel.onWordEntered(newWord: "BETTY")
        
        let collectionItems = wordleMainViewDelegate.lastCollectionListGivenToView
            
        XCTAssertEqual("T", collectionItems[2].letterValue)
        XCTAssertEqual(WordleCollectionItemState.rightPosition, collectionItems[2].state)
        XCTAssertEqual("T", collectionItems[3].letterValue)
        XCTAssertEqual(WordleCollectionItemState.notInWord, collectionItems[3].state)
    }
    
    func test_given_the_solution_is_SANDY_and_the_first_guessed_word_is_AMISS_then_both_only_the_first_S_should_be_the_wrong_position_state() throws{
        
        let wordleMainViewDelegate = wordleMainViewModelTests.getWordleMainViewDelegate()
        let wordListProvider = wordleMainViewModelTests.getWordListProvider(validGeussWordList: ["AMISS"], solutionWordList: ["SANDY"])
        
        let viewModel = wordleMainViewModelTests.getViewModel(wordleMainViewDelegate: wordleMainViewDelegate, wordListProvider: wordListProvider)
        viewModel.initGame()
        
        //simulate user guessing AMISS
        viewModel.onWordEntered(newWord: "AMISS")
        
        let collectionItems = wordleMainViewDelegate.lastCollectionListGivenToView
            
        print(collectionItems.map({ word in
            word.state
        }))
        
        XCTAssertEqual("S", collectionItems[3].letterValue)
        XCTAssertEqual(WordleCollectionItemState.wrongPosition, collectionItems[3].state)
        XCTAssertEqual("S", collectionItems[4].letterValue)
        XCTAssertEqual(WordleCollectionItemState.notInWord, collectionItems[4].state)
    }
    
    //Setting up Mock utils for viewmodel
    private static func getViewModel(wordleMainViewDelegate: WordleMainViewDelegate = getWordleMainViewDelegate(),
                              wordListProvider: WordListProvider = getWordListProvider())-> WordleMainViewModel {
        return WordleMainViewModel(wordleMainViewDelegate: wordleMainViewDelegate, wordListProvider: wordListProvider)
    }
    
    private static func getWordListProvider(validGeussWordList: [String] = ["TESTS"], solutionWordList: [String] = ["TESTS"] ) -> WordListProvider{
        class MockWordListProvider : WordListProvider {
            let validGeussWordList: [String]
            let solutionWordList: [String]
            
            init(validGeussWordList: [String], solutionWordList: [String]){
                self.validGeussWordList = validGeussWordList
                self.solutionWordList = solutionWordList
            }
            
            func getValidGeussWordList() -> [String] {
                return self.validGeussWordList
            }
            
            func getSolutionWordList() -> [String] {
                return solutionWordList
            }
        }
        
        return MockWordListProvider(validGeussWordList: validGeussWordList, solutionWordList: solutionWordList)
    }
    
    class MockWordleMainViewDelegate : WordleMainViewDelegate {
        
        var lastErrorMessageGivenToView: String = ""
        var lastCollectionListGivenToView: [WordleCollectionViewItem] = Array()
        
        func displayTargetWord(targetWord: String) {}
        func showError(errorString: String) {
            lastErrorMessageGivenToView = errorString
        }
        func updateCollectionView(collectionViewArray: [WordleCollectionViewItem]) {
            lastCollectionListGivenToView = collectionViewArray
        }

    }
    
    private static func getWordleMainViewDelegate() -> MockWordleMainViewDelegate{
        return MockWordleMainViewDelegate()
    }
    
}
