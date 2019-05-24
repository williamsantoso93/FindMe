//
//  ViewController.swift
//  FindMe
//
//  Created by William Santoso on 21/05/19.
//  Copyright © 2019 William Santoso. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

enum Level {
    case green
    case red
    case blue
}

class ViewController: UIViewController {
    @IBOutlet weak var meButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lifeView: UIView!
    @IBOutlet weak var remainingTime: UIProgressView!
    
    var meButtonColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var saveColorGreen: [CGFloat] = []
    var saveColorRed: [CGFloat] = []
    var saveColorBlue: [CGFloat] = []
    
    var player: AVAudioPlayer?
    
    var startingTap = true
    
    var nextLevel = false
    var reset = false
    
    var level: Level = .green
    var gameTimer: Timer = Timer()
    
    //setting
    var countIncorrectButton = 9
    let setStartingLife: Int = 10
    let maxRandomMinusLife: Int = 5
    var life: Int = 0
    let oneCycleTime: Float = 2.5
    let timerInterval: Float = 1/100
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //life button
        life = setStartingLife
        createlife()
        
        // starting mebutton position
        recenterMeButton()
        
        // starting mebutton color
        meButtonColor = randomColor()
        meButton.backgroundColor = meButtonColor
        
        
        createIncorrectButton()
        
//        remainingTime.setProgress(true, animated: true)
        remainingTime.alpha = 0
        remainingTime.setProgress(1, animated: false)
//        remainingTime.progress = 1
        
        //create loading indicator
        loadingIndicator.center = view.center
        
        loadingIndicator.frame = CGRect(x: loadingIndicator.frame.minX, y: meButton.frame.maxY + 100, width: loadingIndicator.frame.width, height: loadingIndicator.frame.height)
        
        // jumping meButton and
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 25, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(2)
            self.meButton.transform = CGAffineTransform(translationX: 0, y: 50)
        }) { (finisih) in
            self.loadingIndicator.isHidden = true
        }
    }
    
    //MARK:- manage game timer
    func runTimer() {
        remainingTime.alpha = 1
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timerInterval), target: self, selector: #selector(countdownTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    @objc func countdownTimer(timer: Timer) {
//        let decreaseTime = 1 / oneCycleTime
//        print(decreaseTime)
        if remainingTime.progress > 0 {
//            remainingTime.progress -= decreaseTime
            remainingTime.setProgress((remainingTime.progress - (timerInterval / oneCycleTime)), animated: false)
        } else {
            gameTimer.invalidate()
//            print("finish")
            incorrectAction()
        }
//        print(remainingTime.progress)
    }
    
    func resetTimer() {
        remainingTime.setProgress(1, animated: false)
        runTimer()
    }
    
    
    //MARK:- manage random
    func randomCoor(backView: UIView) -> CGRect {
        let ranW = CGFloat.random(in: 50...150)
        let ranH = ranW
        
        let ranX = CGFloat.random(in: 0...(backView.frame.width - ranW))
        let ranY = CGFloat.random(in: 80...(backView.frame.height - ranH - 50))
        
        return CGRect(x: ranX, y: ranY, width: ranW, height: ranH)
    }
    
    func randomColor() -> UIColor {
        var randomRed: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorRed {
            while (randomRed == color) {
                randomRed = CGFloat.random(in: 0.5...1.0)
            }
        }
        saveColorRed.append(randomRed)
        
        var randomGreen: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorGreen {
            while (randomGreen == color) {
                randomGreen = CGFloat.random(in: 0.5...1.0)
            }
        }
        saveColorGreen.append(randomGreen)
        
        var randomBlue: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorBlue {
            while (randomBlue == color) {
                randomBlue = CGFloat.random(in: 0.5...1.0)
            }
        }
        saveColorBlue.append(randomBlue)
        
        let ranAlpha:CGFloat = 1.0
        
        
        switch level {
        case .green :
            randomRed = 0.5
            randomBlue = 0.0
        case .red :
            randomGreen = 0.25
            randomBlue = 0.25
        case .blue :
            randomRed = 0.25
            randomGreen = 0.25
        }
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: ranAlpha)
    }
    
    
    //MARK:- manage life
    func createlife() {
        for i in 0 ... (setStartingLife - 1) {
            let lifeButton = UIButton()
            
            lifeButton.frame = CGRect(x: 20 + (23 * i), y: 0, width: 20, height: 20)
            lifeButton.layer.borderWidth = 1
            lifeButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            lifeButton.tag = i + 1
            lifeButton.layer.cornerRadius = lifeButton.frame.width / 2
            lifeButton.isEnabled = false
            
            lifeButton.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
            lifeButton.alpha = 0
            
            self.lifeView.addSubview(lifeButton)
        }
    }
    
    func lifeUpdate() {
        if life < 0 {
            life = 0
        }
        
        for view in self.lifeView.subviews as [UIView] {
            if let btn = view as? UIButton {
                if btn.tag <= life {
                    btn.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                } else {
                    btn.backgroundColor = nil
                }
                btn.alpha = 1
            }
        }
    }
    
    
    //MARK:- manage incorrect button
    func createIncorrectButton() {
        for _ in 1...countIncorrectButton {
            let addButton = UIButton()
            
            addButton.backgroundColor = randomColor()
            
            addButton.frame = randomCoor(backView: view)
            addButton.layer.cornerRadius = addButton.frame.width / 2
            
            addButton.addTarget(self, action: #selector(incorrectButtonAction), for: .touchUpInside)
            
            addButton.alpha = 0
            
            self.view.addSubview(addButton)
        }
    }
    
    @objc func incorrectButtonAction(sender: UIButton!) {
        incorrectAction()
    }
    
    func incorrectAction() {
        life -= Int.random(in: 1 ... maxRandomMinusLife)
        lifeUpdate()
        
        //sound error + animate
        playSound(name: "error")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            self.incorrectAnimation()
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }, completion: { (finished) in
            })
        }
        
        gameTimer.invalidate()
        
        if life <= 0 {
//            gameTimer.invalidate()
            gameOver()
        } else {
            resetTimer()
        }
    }
    
    
    //MARK:- manage animation
    @objc func startAnimation() {
        UIView.animate(withDuration: 1, animations: {
            self.meButton.alpha = 1
            for view in self.view.subviews as [UIView] {
                if let btn = view as? UIButton {
                    if (btn.tag != 1) {
                        UIView.animate(withDuration: 0.2) {
                            btn.alpha = 1
                            
                            btn.backgroundColor = self.randomColor()
                        }
                    }
                    self.view.sendSubviewToBack(self.meButton)
                }
            }
        }) { (finish) in
            self.shuffleIncorrectButton()
        }
    }
    
    func shuffleIncorrectButton() {
        let dur: TimeInterval =  0.3
        let times: TimeInterval = 7
        let totalDur: TimeInterval = dur * times
        
        UIView.animateKeyframes(withDuration: totalDur, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: dur/totalDur, animations: {
                
                self.meButton.frame = self.randomCoor(backView: self.view)
                self.meButton.layer.cornerRadius = self.meButton.frame.width / 2
            })
            UIView.addKeyframe(withRelativeStartTime: dur, relativeDuration: dur/totalDur, animations: {
                
                self.meButton.frame = self.randomCoor(backView: self.view)
                self.meButton.layer.cornerRadius = self.meButton.frame.width / 2
            })
            UIView.addKeyframe(withRelativeStartTime: dur*2, relativeDuration: dur/totalDur, animations: {
                
                self.meButton.frame = self.randomCoor(backView: self.view)
                self.meButton.layer.cornerRadius = self.meButton.frame.width / 2
            })
            
            UIView.addKeyframe(withRelativeStartTime: dur*3, relativeDuration: dur/totalDur, animations: {
                
                for view in self.view.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                    }
                }
            })
            UIView.addKeyframe(withRelativeStartTime: dur*4, relativeDuration: dur/totalDur, animations: {
                
                for view in self.view.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                    }
                }
            })
            UIView.addKeyframe(withRelativeStartTime: dur*5, relativeDuration: dur/totalDur, animations: {
                
                for view in self.view.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                    }
                }
            })
            UIView.addKeyframe(withRelativeStartTime: dur*6, relativeDuration: dur/totalDur, animations: {
                
                for view in self.view.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                    }
                }
            })
        }) { (finish) in
            
            for view in self.view.subviews as [UIView] {
                if let btn = view as? UIButton {
                    UIView.animate(withDuration: 0.2) {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                    }
                }
            }
            self.view.sendSubviewToBack(self.meButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                for view in self.lifeView.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.alpha = 1
                    }
                }
            })
//            self.remainingTime.alpha = 1
            self.runTimer()
        }
    }
    
    func incorrectAnimation() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                UIView.animate(withDuration: 0.2) {
                    btn.frame = self.randomCoor(backView: self.view)
                    btn.layer.cornerRadius = btn.frame.width / 2
                    if btn.tag != 1 {
                        btn.backgroundColor = self.randomColor()
                    }
                }
            }
        }
        self.view.sendSubviewToBack(meButton)
    }
    
    
    //MARK:- manage meButton
    @IBAction func meButtonDidTap(_ sender: Any) {
        gameTimer.invalidate()
        if reset {
            // mebutton color
            meButtonColor = randomColor()
            meButton.backgroundColor = meButtonColor
            life = setStartingLife
            createlife()
            lifeUpdate()
            createIncorrectButton()
            
            UIView.animate(withDuration: 1, delay: 0, animations: {
                self.incorrectAnimation()
            }, completion: { (finish) in
                self.startAnimation()
            })
            reset = false
        } else if startingTap {
            //first time start game
            if !nextLevel {
                UIView.animate(withDuration: 1, delay: 0, animations: {
                    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }, completion: { (finish) in
                    self.startAnimation()
                })
            } else {
                createlife()
                lifeUpdate()
                createIncorrectButton()
                
                UIView.animate(withDuration: 1) {
                    self.startAnimation()
                }
            }
            
            startingTap = false
        } else {
            if !nextLevel {
                //win level
                remainingTime.alpha = 0
                remainingTime.setProgress(1, animated: false)
                meButtonBackgroundAnimate()
                view.bringSubviewToFront(meButton)
                
                switch level {
                case .green :
                    level = .red
                    countIncorrectButton += 5
                case .red :
                    level = .blue
                    countIncorrectButton += 5
                case .blue :
                    level = .green
                    countIncorrectButton += 5
                }
                
                nextLevel = true
                
                // mebutton color
                meButtonColor = randomColor()
                meButton.backgroundColor = meButtonColor
                
                recenterMeButton()
                lifeUpdate()
                startNewLevel()
            } else {
                
                //start next level
                createlife()
                lifeUpdate()
                createIncorrectButton()
                
                UIView.animate(withDuration: 1) {
                    self.startAnimation()
                }
                nextLevel = false
            }
        }
    }
    
    func meButtonBackgroundAnimate() {
        playSound(name: "error")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        }) { (finished) in
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            })
        }
    }
    
    func recenterMeButton() {
        // starting mebutton position
        meButton.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        meButton.center = view.center
        meButton.layer.cornerRadius = meButton.frame.width / 2
        meButton.alpha = 1
    }
    
    func startNewLevel() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                if btn.tag != 1 {
                    btn.removeFromSuperview()
                }
            }
        }
    }
    
    
    //MARK:- manage game restart
    func createFailedAndRestart() {
        var addButton = UIButton()
        
        addButton.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        addButton.center = view.center
        addButton.transform = CGAffineTransform(translationX: 0, y: -150)
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.setImage(#imageLiteral(resourceName: "GameOver"), for: .normal)
        addButton.tag = 3
        addButton.isEnabled = false
        
        self.view.addSubview(addButton)
        
        addButton = UIButton()
        
        addButton.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        addButton.center = view.center
        addButton.transform = CGAffineTransform(translationX: 0, y: 150)
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.setImage(#imageLiteral(resourceName: "Restart"), for: .normal)
        addButton.tag = 4
        addButton.addTarget(self, action: #selector(restartAction), for: .touchUpInside)
        
        self.view.addSubview(addButton)
    }
    
    @objc func restartAction(sender: UIButton!) {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                if btn.tag != 1 {
                    btn.removeFromSuperview()
                }
            }
        }
        for view in self.lifeView.subviews as [UIView] {
            if let btn = view as? UIButton {
                btn.removeFromSuperview()
            }
        }
        
        nextLevel = false
        level = .green
        saveColorGreen.removeAll()
        saveColorRed.removeAll()
        saveColorBlue.removeAll()
        meButton.backgroundColor = randomColor()
        
        restart()
    }
    
    func restart() {
        //life button
//        life = setStartingLife
        createlife()
        
        // starting mebutton position
        recenterMeButton()
        
        reset = true
    }
    
    func gameOver() {
        remainingTime.alpha = 0
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                btn.alpha = 0
            }
        }
        createFailedAndRestart()
    }
    
    //MARK:- effect
    func playSound(name: String) {
        let path = Bundle.main.path(forResource: name, ofType: "wav")
        let url = URL(fileURLWithPath: path ?? "")
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

