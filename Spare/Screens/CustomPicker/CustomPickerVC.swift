//
//  CustomPickerVC.swift
//  Spare
//
//  Created by Matt Quiros on 14/08/2016.
//  Copyright © 2016 Matt Quiros. All rights reserved.
//

import UIKit

class CustomPickerVC: UIViewController {
    
    enum ViewID: String {
        case Header = "Header"
        case ItemCell = "ItemCell"
    }
    
    let customView = __CPVCView.instantiateFromNib() as __CPVCView
    
    var delegate: UITableViewDataSource & UITableViewDelegate {
        didSet {
            self.customView.tableView.dataSource = self.delegate
            self.customView.tableView.delegate = self.delegate
        }
    }
    
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnDimView))
        tapGesture.cancelsTouchesInView = false
        
        self.customView.dimView.addGestureRecognizer(tapGesture)
        self.customView.tableView.register(CustomPickerCell.nib(), forCellReuseIdentifier: ViewID.ItemCell.rawValue)
    }
    
    func handleTapOnDimView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
