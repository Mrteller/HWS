//
//  CardViewController.swift
//  Project 37
//
//  Created by Paul on 20.05.2019.
//  Copyright © 2019 Paul. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    weak var delegate: MainViewController!
    var front: UIImageView!
    var back: UIImageView!
    var isCorrect = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        front = UIImageView(image: UIImage(named: "cardBack"))
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
        front.isHidden = true
        back.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.back.alpha = 1
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTaped))
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tap)
    }
    
    @objc func cardTaped() {
        delegate.cardTaped(self)
    }
    
    @objc func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    @objc func wasTapped() {
        UIView.transition(with: view, duration: 0.7, options: [.transitionFlipFromTop], animations: { [unowned self] in
            self.back.isHidden = true
            self.front.isHidden = false
        }, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
