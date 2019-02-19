//
//  UIView+utils.swift
//  Project 33
//
//  Created by Paul on 19.02.2019.
//  Copyright © 2019 Paul. All rights reserved.
//
// TODO: use it!
import UIKit

extension UIView {

    func alignAndSenter(to otherView: UIView?) {
        if let av = (otherView ?? superview) {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.leftAnchor.constraint(equalTo: av.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: av.trailingAnchor).isActive = true
            self.topAnchor.constraint(equalTo: av.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: av.bottomAnchor).isActive = true
        }

    }
}
