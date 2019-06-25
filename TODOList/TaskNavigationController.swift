//
//  TaskNavigationController.swift
//  TODOList
//
//  Created by Kang Li on 2019/6/25.
//  Copyright © 2019 thoughtworks. All rights reserved.
//

import UIKit

class TaskNavigationController: UINavigationController {
    
    private var advertiseView: UIView?
    var adView: UIView? {
        didSet {
            advertiseView = adView!
            advertiseView?.frame = self.view.bounds
            self.view.addSubview(advertiseView!)
            UIView.animate(withDuration: 1.5, animations: { [weak self] in
                self?.advertiseView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self?.advertiseView?.alpha = 0
            }) { [weak self] (isFinish) in
                self?.advertiseView?.removeFromSuperview()
                self?.advertiseView = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
