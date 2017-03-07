//
//  _ELVCSectionHeader.swift
//  Spare
//
//  Created by Matt Quiros on 07/03/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit

class _ELVCSectionHeader: UITableViewHeaderFooterView, Themeable {
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leftLabel.font = Font.regular(14)
        self.leftLabel.numberOfLines = 1
        self.leftLabel.textAlignment = .left
        
        self.rightLabel.font = Font.regular(14)
        self.rightLabel.numberOfLines = 1
        self.rightLabel.textAlignment = .right
        
        self.applyTheme()
    }
    
    func applyTheme() {
        self.contentView.backgroundColor = Global.theme.expenseListSectionHeaderBackgroundColor
        self.leftLabel.textColor = Global.theme.expenseListSectionHeaderTextColor
        self.rightLabel.textColor = Global.theme.expenseListSectionHeaderTextColor
    }
    
}
