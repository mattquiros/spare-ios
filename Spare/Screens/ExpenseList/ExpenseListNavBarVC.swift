//
//  ExpenseListNavBarVC.swift
//  Spare
//
//  Created by Matt Quiros on 14/03/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

class ExpenseListNavBarVC: BaseNavBarVC {
    
    let editingNavigationBar = UINavigationBar(frame: CGRect.zero)
    let expenseListVC = ExpenseListVC(nibName: nil, bundle: nil)
    
    init() {
        super.init(rootViewController: self.expenseListVC)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editingNavigationBar.isTranslucent = false
        self.editingNavigationBar.barTintColor = Global.theme.color(for: .barBackground)
        self.editingNavigationBar.tintColor = Global.theme.color(for: .barTint)
        self.editingNavigationBar.alpha = 0
        self.editingNavigationBar.setItems([self.expenseListVC.editingNavigationItem], animated: false)
        
        self.view.addSubview(self.editingNavigationBar)
        self.view.backgroundColor = Global.theme.color(for: .mainBackground)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // The editingNavigationBar's y and height depend on the size of the status bar.
        let editingNavigationBarY = UIApplication.shared.statusBarFrame.size.height > 20 ? self.navigationBar.frame.origin.y : 0
        let heightOffset = UIApplication.shared.statusBarFrame.size.height > 20 ? 0 : UIApplication.shared.statusBarFrame.size.height
        
        self.editingNavigationBar.frame = CGRect(x: 0,
                                                 y: editingNavigationBarY,
                                                 width: self.navigationBar.frame.size.width,
                                                 height: self.navigationBar.frame.size.height + heightOffset)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.navigationBar.alpha = editing ? 0 : 1
        self.editingNavigationBar.alpha = editing ? 1 : 0
        
//        self.navigationBar.isUserInteractionEnabled = false
//        self.editingNavigationBar.isUserInteractionEnabled = false
//        
//        UIView.animateKeyframes(withDuration: 0.25,
//                                delay: 0,
//                                options: [.layoutSubviews],
//                                animations: {[unowned self] in
//                                    UIView.addKeyframe(withRelativeStartTime: 0,
//                                                       relativeDuration: 0.5,
//                                                       animations: {
//                                                        self.navigationBar.alpha = editing ? 0 : 1
//                                    })
//                                    UIView.addKeyframe(withRelativeStartTime: 0.5,
//                                                       relativeDuration: 0.5,
//                                                       animations: {
//                                                        self.editingNavigationBar.alpha = editing ? 1 : 0
//                                    })
//            },
//                                completion: {[unowned self] _ in
//                                    self.navigationBar.isUserInteractionEnabled = true
//                                    self.editingNavigationBar.isUserInteractionEnabled = true
//        })
    }
    
}
