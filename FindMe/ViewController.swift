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
    
    var CorretButtonColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var saveColorGreen: [CGFloat] = []
    var saveColorRed: [CGFloat] = []
    var saveColorBlue: [CGFloat] = []
    
    var player: AVAudioPlayer?
    
    var startingTap = true
    
    var nextLevel = false
    var reset = false
    
    var level: Level = .green
    
    //setting
    let countRandomButton = 1
    let setStartingLife: Int = 10
    let maxRandomMinusLife: Int = 5
    var life: Int = 0
    
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
        CorretButtonColor = randomColor()
        meButton.backgroundColor = CorretButtonColor
        print(CorretButtonColor)
        
        
        createRandomButton()
        
        //timer on delay start animation
        //        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: false)
        
        
        loadingIndicator.center = view.center
        
        loadingIndicator.frame = CGRect(x: loadingIndicator.frame.minX, y: meButton.frame.maxY + 100, width: loadingIndicator.frame.width, height: loadingIndicator.frame.height)
        
        
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 25, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(2)
            self.meButton.transform = CGAffineTransform(translationX: 0, y: 50)
        }) { (finisih) in
            self.loadingIndicator.isHidden = true
        }
    }
    //MARK:- manage random
    func randomCoor(backView: UIView) -> CGRect {
        let ranW = CGFloat.random(in: 50...150)
        let ranH = ranW
        
        let ranX = CGFloat.random(in: 0...(backView.frame.width - ranW))
        let ranY = CGFloat.random(in: 52...(backView.frame.height - ranH))
        
        return CGRect(x: ranX, y: ranY, width: ranW, height: ranH)
    }
    
    func randomColor() -> UIColor {
        var randomRed: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorRed {
            while (randomRed == color) {
                randomRed = CGFloat.random(in: 0.5...1.0)
            }
            saveColorRed.append(randomRed)
        }
        
        var randomGreen: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorGreen {
            while (randomGreen == color) {
                randomGreen = CGFloat.random(in: 0.5...1.0)
            }
            saveColorGreen.append(randomGreen)
        }
        
        var randomBlue: CGFloat = CGFloat.random(in: 0.5...1.0)
        for color in saveColorBlue {
            while (randomBlue == color) {
                randomBlue = CGFloat.random(in: 0.5...1.0)
            }
            saveColorBlue.append(randomGreen)
        }
        
        let ranAlpha:CGFloat = 1.0
        
        
        switch level {
        case .green :
            randomRed = 0.5
            randomBlue = 0.0
        case .red :
            randomGreen = 0.5
            randomBlue = 0.0
        case .blue :
            randomRed = 0.5
            randomGreen = 0.0
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
    
    func lifeViewUpdate() {
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
                if (btn.tag == 3) || (btn.tag == 4) {
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
        
        restart()
    }
    
    func recenterMeButton() {
        // starting mebutton position
        meButton.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        meButton.center = view.center
        meButton.layer.cornerRadius = meButton.frame.width / 2
        meButton.alpha = 1
    }
    
    func restart() {
        //life button
        createlife()
        
        // starting mebutton position
        recenterMeButton()
        
        reset = true
    }
    
    //MARK:- manage random button
    func createRandomButton() {
        for _ in 1...countRandomButton {
            let addButton = UIButton()
            
            addButton.backgroundColor = randomColor()
            
            addButton.frame = randomCoor(backView: view)
            addButton.layer.cornerRadius = addButton.frame.width / 2
            
            addButton.addTarget(self, action: #selector(randomButtonAction), for: .touchUpInside)
            
            addButton.alpha = 0
            
            self.view.addSubview(addButton)
        }
    }
    
    @objc func randomButtonAction(sender: UIButton!) {
        incorrectAction()
    }
    
    func incorrectAction() {
        life -= Int.random(in: 1 ... maxRandomMinusLife)
        lifeViewUpdate()
        //sound error + animate
        playSound(name: "error")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            self.incorrectAnimation()
        }) { (finished) in
            //self.recreateRandomButton()
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }, completion: { (finished) in
            })
        }
        //        print(life)
        
        if life > 0 {
            //            animateMeAndHideButton()
            //            self.incorrectAnimation()
        } else {
            ////            sleep(1)
            //            for _ in 1...5 {
            //                UIView.animate(withDuration: 0.2, animations: {
            //                    self.view.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            //                    self.incorrectAnimation()
            //                }) { (finished) in
            //                    //self.recreateRandomButton()
            //                    UIView.animate(withDuration: 0.2, animations: {
            //                        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //                    }, completion: { (finished) in
            //                    })
            //                }
            //
            ////                sleep(1)
            //                playSound(name: "error")
            //                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //
            //            }
            gameOver()
        }
    }
    
    //MARK:- animation
    func shuffleRandomButton() {
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
            self.incorrectAnimation()
//            self.animateMeAndHideButton()
            
            UIView.animate(withDuration: 0.2, animations: {
                
                for view in self.lifeView.subviews as [UIView] {
                    if let btn = view as? UIButton {
                        btn.alpha = 1
                    }
                }
            })
        }
    }
    
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
            self.shuffleRandomButton()
        }
    }
    
    func incorrectAnimation() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
//                if (btn.tag != 1) && (btn.tag != 2) {
                    UIView.animate(withDuration: 0.2) {
                        btn.frame = self.randomCoor(backView: self.view)
                        btn.layer.cornerRadius = btn.frame.width / 2
                        btn.backgroundColor = self.randomColor()
                    }
//                } else {
//                    self.view.sendSubviewToBack(meButton)
//                }
                
            }
        }
        self.view.sendSubviewToBack(meButton)
    }
    
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
    
    func gameOver() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                btn.alpha = 0
            }
        }
        
        createFailedAndRestart()
    }
    
    
    func correctAction() {
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
    
    func startNewLevel() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                if btn.tag != 1 {
                    btn.removeFromSuperview()
                }
            }
        }
        
//        for view in self.lifeView.subviews as [UIView] {
//            if let btn = view as? UIButton {
//                btn.removeFromSuperview()
//            }
//        }
        
        startingTap = true
    }
    
    @IBAction func correctButtonDidTap(_ sender: Any) {
        print("\(startingTap)     \(nextLevel)     \(reset)")
        if reset {
            print(level)
            // mebutton color
            CorretButtonColor = randomColor()
            print(CorretButtonColor)
            meButton.backgroundColor = CorretButtonColor
            life = setStartingLife
            
            createlife()
            createRandomButton()
            
            UIView.animate(withDuration: 1, delay: 0, animations: {
                self.incorrectAnimation()
            }, completion: { (finish) in
                self.startAnimation()
            })
            reset = false
        } else if startingTap {
            
            if !nextLevel {
                UIView.animate(withDuration: 1, delay: 0, animations: {
                    self.incorrectAnimation()
                    self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                }, completion: { (finish) in
                    self.startAnimation()
                })
            } else {
                
                createlife()
                createRandomButton()
                
                UIView.animate(withDuration: 1) {
                    self.startAnimation()
                }
            }
            
            startingTap = false
        } else {
            if !nextLevel {
                
                correctAction()
                view.bringSubviewToFront(meButton)
                
                switch level {
                case .green :
                    level = .red
                case .red :
                    level = .blue
                case .blue :
                    level = .green
                }
                
                //            print(level)
                
                nextLevel = true
                
                // mebutton color
                CorretButtonColor = randomColor()
                meButton.backgroundColor = CorretButtonColor
                
                //            life = setStartingLife
                
                recenterMeButton()
                lifeViewUpdate()
                startNewLevel()
            } else {
                
                createlife()
                createRandomButton()
                
                UIView.animate(withDuration: 1) {
                    self.startAnimation()
                }
            }
        }
    }
}

