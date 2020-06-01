//
//  AssessmentTableViewCell.swift
//  CW2
//
//  Created by Guest 1 on 31/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit

class AssessmentTableViewCell: UITableViewCell {
    
    //A custom cell view controller that allows a cell to display more information
    
    @IBOutlet weak var cellAssessmentName: UILabel!
    @IBOutlet weak var cellModuleName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
