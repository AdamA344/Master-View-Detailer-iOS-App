//
//  TaskTableViewCell.swift
//  CW2
//
//  Created by Guest 1 on 31/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    //A custom cell view controller that allows a cell to display more information
    
    @IBOutlet weak var taskNameCell: UILabel!
    @IBOutlet weak var taskNotesCell: UILabel!
    @IBOutlet weak var taskDueDateCell: UILabel!
    @IBOutlet weak var taskDaysLeftCell: UILabel!
    @IBOutlet weak var taskGraphProgress: taskProgressView!
    @IBOutlet weak var labelPercentage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
