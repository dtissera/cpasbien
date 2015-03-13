//
//  UIViewController+Extension.swift
//  cpasbien
//
//  Created by David Tisserand on 28/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func reavel_setup() {
        let revealController = self.revealViewController()
        self.navigationController?.navigationBar.addGestureRecognizer(revealController.panGestureRecognizer())
        
        let image = UIImage(named: "menu48")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        let revealButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Bordered, target: self.revealViewController(), action: Selector("revealToggle:"))
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
}
