//
//  ViewController.swift
//  Hangman game
//
//  Created by Aleksandr on 07.06.2022.
//

import UIKit

class ViewController: UIViewController {
    var currentWord: UILabel!
    var imageView: UIImageView!
    var lettersArray = [UIButton]()
    var refresh: UIButton!
    
    var guessWord = String()
    var wordsArray = [String]()
    var mistakes = 0 {
        didSet {
            changeImage()
            
            if mistakes == mistakesMax {
                showLost()
            }
        }
    }
    let mistakesMax = 10
    
    override func loadView() {
        super.loadView()
        
        currentWord = UILabel()
        currentWord.text = " "
        currentWord.font = UIFont.systemFont(ofSize: 44)
        currentWord.textAlignment = .center
        currentWord.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentWord)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        let alphabet = ["A" , "B" , "C" , "D" , "E" , "F" , "G" , "H" , "I" , "J" , "K" , "L" , "M" , "N", "O" , "P" , "Q" , "R" , "S" , "T" , "U" , "V" , "W", "X" , "Y", "Z"]
        let size = 50
        let offset = 5
        var viewWidth: Int {
            return Int(view.frame.size.width) < 600 ? Int(view.frame.size.width) : 600
        }
        let columnsInRow = (viewWidth - 40) / (size + offset)
        var rows: Int {
            guard columnsInRow > 0 else { return 0 }
            return alphabet.count % columnsInRow == 0 ? alphabet.count / columnsInRow : alphabet.count / columnsInRow + 1
        }

        for row in 0..<rows {
            for column in 0..<columnsInRow {
                guard lettersArray.count < alphabet.count else { break }
                let button = UIButton(configuration: .gray())
                buttonsView.addSubview(button)
                button.frame = CGRect(x: column * (size + offset), y: row * (size + offset), width: size, height: size)
                button.titleLabel?.textColor = .red
                
                lettersArray.append(button)
            }
        }
        
        for (pos, button) in lettersArray.enumerated() {
            button.isExclusiveTouch = true
            button.setTitle(alphabet[pos], for: .normal)
            button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        refresh = UIButton()
        refresh.setTitle("↻", for: .normal)
        refresh.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        refresh.setTitleColor(.systemBlue, for: .normal)
        refresh.addTarget(self, action: #selector(loadGame), for: .touchUpInside)
        refresh.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refresh)
        
        NSLayoutConstraint.activate([
            currentWord.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currentWord.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            refresh.topAnchor.constraint(equalTo: currentWord.topAnchor, constant: 10),
            refresh.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: currentWord.bottomAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.6),
        
            buttonsView.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 50),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsView.widthAnchor.constraint(equalToConstant: CGFloat(columnsInRow * (size + offset))),
            buttonsView.heightAnchor.constraint(equalToConstant: CGFloat(rows * (size + offset)))
        ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.global().async { [weak self] in
            guard let path = Bundle.main.path(forResource: "words", ofType: "txt") else { return }
            guard let wordsString = try? String(contentsOfFile: path) else { return }
            self?.wordsArray = wordsString.components(separatedBy: "\n")
            
            self?.performSelector(onMainThread: #selector(Self.loadGame), with: nil, waitUntilDone: false)
        }
    }
    
    func changeImage() {
        guard let image = UIImage(named: "\(mistakes)") else { return }
        
        if self.traitCollection.userInterfaceStyle == .dark {
            let beginImage = CIImage(image: image)
            if let filter = CIFilter(name: "CIColorInvert") {
                filter.setValue(beginImage, forKey: kCIInputImageKey)
                let newImage = UIImage(ciImage: filter.outputImage!)
                imageView.image = newImage
            }
        } else {
            imageView.image = image
        }
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        sender.isHidden = true
        
        guard let letter = sender.titleLabel?.text else { return }
        
        if guessWord.contains(letter) {
            guard var currentWordArray = currentWord.text?.components(separatedBy: " ") else { return }
            
            for (pos, char) in guessWord.enumerated() {
                if char == Character(letter) {
                    currentWordArray[pos] = letter
                }
            }
            currentWord.text = currentWordArray.joined(separator: " ")
            
            if guessWord == currentWord.text?.replacingOccurrences(of: " ", with: "") {
                showWin()
            }
        } else {
            mistakes += 1
        }
    }
    
    func showWin() {
        let ac = UIAlertController(title: "You did it!", message: "Do you want to start a new game?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.loadGame()
        }))
        present(ac, animated: true)
    }
    
    func showLost() {
        let ac = UIAlertController(title: "You lost. The word was \(guessWord).", message: "Do you want to start a new game?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.loadGame()
        }))
        present(ac, animated: true)
    }
    
    @objc func loadGame() {
        guessWord = wordsArray.randomElement()!.uppercased()
        if guessWord.count >= 8 {
            loadGame()
        }
        
        mistakes = 0
        
        for button in lettersArray {
            button.isHidden = false
        }
        currentWord.text = String(repeating: "_ ", count: guessWord.count)
        currentWord.text?.removeLast()
    }

    // Set the shouldAutorotate to False
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }

}
