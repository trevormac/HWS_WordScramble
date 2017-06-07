//
//  ViewController.swift
//  Word_Scramble
//
//  Created by Trevor MacGregor on 2017-06-05.
//  Copyright © 2017 TeevoCo. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }else{
            allWords = ["silkworm"]
        }
        
        startGame()
    }
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    //MARK: Start Game
    func startGame() {
        //shuffles our array of words
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        //assigns our VC's title to the word
        title = allWords[0]
        //removes all values from our usedWords array, which we'll be using to store our players answers
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
//MARK: Prompt for answer
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){ [unowned self, ac] (action: UIAlertAction!)
            in
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
    }
        ac.addAction(submitAction)
        present(ac, animated: true)
        
  }
    
//MARK:Submit answer
     func submit(answer:String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                }else{
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up you know!"
                }
            } else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        }else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell the word from '\(title!.lowercased())'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        
    }
    
    func isPossible(word:String) -> Bool {
        var tempWord = title!.lowercased()
        //loop through every letter and see if it exists in the 8 letter start word. If it does, remove it from the start word, then continue.  So, if we try to use a letter twice, it will exist the first time, but then get removed so it doesn't exist the next time, and the check will fail.

        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            }else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word:String) -> Bool {
        return !usedWords.contains(word)
    }

    func isReal(word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
        
    }

}

