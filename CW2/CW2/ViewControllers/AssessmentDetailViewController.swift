//
//  AssessmentDetailViewController.swift
//  CW2
//
//  Created by Guest 1 on 26/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit

class AssessmentDetailViewController: UIViewController {
    
    @IBOutlet weak var labelAssessmentName: UILabel!
    @IBOutlet weak var assessmentTextViewNotes: UITextView!
    @IBOutlet weak var labelModuleName: UILabel!
    @IBOutlet weak var labelAssessmentLevel: UILabel!
    @IBOutlet weak var labelAssessmentValue: UILabel!
    @IBOutlet weak var labelMarkAwarded: UILabel!
    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var OverallProgressView: OverallTaskProgressView!
    @IBOutlet weak var OverallPercentageLabel: UILabel!
    @IBOutlet weak var timeLeft: timeLeftDisplayView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    
    
    //setting values as empty until a assessment is picked
    var textNotes = ""
    var assessmentName = ""
    var moduleName = ""
    var assessmentLevel = ""
    var assessmentValue = ""
    var assessmentMarkAwarded = ""
    var assessmentDueDate = Date()
    var formatter = DateFormatter()
    var assessment:Assessment?
    var progress = 0.0
    var currentDate = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //assigning values from the database to the labels
        labelAssessmentName.text = assessmentName
        assessmentTextViewNotes.text = textNotes
        labelModuleName.text = moduleName
        labelAssessmentLevel.text = assessmentLevel
        labelAssessmentValue.text = assessmentValue
        labelMarkAwarded.text = assessmentMarkAwarded
        OverallPercentageLabel.text = ("\(progress)" + "%")
        formatter.dateFormat = "d MMM yyyy"
        let formattedDateInString = formatter.string(from: assessmentDueDate)
        labelDueDate.text = formattedDateInString
        //setting the values to the length of the graph 
        OverallProgressView.setProgressAnimation(duration: 1.0, value: Float(progress)/100)
        
        
        // sets the difference between dates for the graph and label
        let remainingDays = daysBetween(date1: currentDate, date2: assessmentDueDate)
        let daysLeftText = daysBetweenText(date1: currentDate, date2: assessmentDueDate)
        timeLeft.setProgressAnimation(duration: 1.0, value: Float(remainingDays)/100)
        daysLeftLabel.text = ("\(daysLeftText)" + " days left")
        
    }
    
    //calculated the diffrence in days between 2 dates 
    func daysBetween(date1:Date, date2:Date) ->Int
    {
        //this is seconds
        let secs = self.assessmentDueDate.timeIntervalSince(self.currentDate)
        //to days
        let days = secs/(60*60*24)
        let days2 = 100/days
        return Int(days2)
    }
    
    func daysBetweenText(date1:Date, date2:Date) ->Int
    {
        //this is seconds
        let secs = self.assessmentDueDate.timeIntervalSince(self.currentDate)
        //to days
        let days = 1 + (secs/(60*60*24))
        return Int(days)
    }
    
}
