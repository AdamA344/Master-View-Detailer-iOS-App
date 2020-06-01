//
//  AddTaskViewController.swift
//  CW2
//
//  Created by Guest 1 on 27/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class AddTaskViewController: UIViewController {
    @IBOutlet weak var labelTaskName: UITextField!
    @IBOutlet weak var labelAssessmentName: UITextField!
    @IBOutlet weak var labelDaysTillCompletion: UITextField!
    @IBOutlet weak var labelNotes: UITextField!
    @IBOutlet weak var labelStartDate: UIDatePicker!
    @IBOutlet weak var labelEndDate: UIDatePicker!
    @IBOutlet weak var taskReminder: UISwitch!
    @IBOutlet weak var labelPercentage: UITextField!
    
    
    let defaults = UserDefaults.standard
    
    var assessment:Assessment?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gives the pop up the same assessment name as the selected cell
        labelAssessmentName.text = self.assessment?.assessmentName
        
        //data persistance
        let saveSelector = #selector(saveTextFields)
        let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: saveSelector, name: UIApplication.willResignActiveNotification, object: nil)
        
        let lTN = defaults.string(forKey: "labelTaskName")
        let lDTC = defaults.string(forKey: "lavelDaysLeft")
        let lN = defaults.string(forKey: "labelNotes")
        let lP = defaults.string(forKey: "percent")
        
        self.labelTaskName.text = lTN
        self.labelDaysTillCompletion.text = lDTC
        self.labelNotes.text = lN
        self.labelPercentage.text = lP
    }
    
    @objc func saveTextFields(){
        defaults.set(self.labelTaskName.text, forKey: "labelTaskName")
        defaults.set(self.labelDaysTillCompletion.text, forKey: "lavelDaysLeft")
        defaults.set(self.labelNotes.text, forKey: "labelNotes")
        defaults.set(self.labelPercentage.text, forKey: "percent")
    }
    
    func addTaskValidation(){
        // updates the database with the new data from the textfields 
        let task = Tasks(context: context)
        task.assessment = assessment?.assessmentName
        task.taskName = labelTaskName.text
        task.daysTillCompletion = labelDaysTillCompletion.text
        task.notes = labelNotes.text
        task.startDate = labelStartDate.date
        task.taskDueDate = labelEndDate.date
        task.taskPercentage = Double(labelPercentage.text ?? "") ?? 0
        assessment?.addToTasks(task)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        // gives application access to push data to the calender app
        if taskReminder.isOn
        {
            let eventStore : EKEventStore = EKEventStore()
            eventStore.requestAccess(to: EKEntityType.reminder, completion:
                {(granted, error) in
                    if !granted {
                        print("Access to store not granted")
                    }
            })
            //this is how you set up access for the calendar
            eventStore.requestAccess(to: .event) { (granted, error) in
                if (granted) && (error == nil) {
                    print("granted \(granted)")
                    print("error \(error)")
                    
                    let event:EKEvent = EKEvent(eventStore: eventStore)
                    
                    event.title = task.taskName
                    event.startDate = task.startDate
                    event.endDate = task.taskDueDate
                    event.notes = task.notes
                    //create an alarm (alert on the calendar event)
                    let alarm:EKAlarm = EKAlarm()
                    alarm.relativeOffset = 60 * -60 //1 hour before in seconds
                    //add the alarm
                    event.addAlarm(alarm)
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                        let alert = UIAlertController(title: "Event could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    print("Saved Event")
                    let alert = UIAlertController(title: "Saved", message:"Event has been saved to your Calendar",preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    
                    print("failed to save event with error : \(String(describing: error)) or access not granted")
                }
            }
        }
    }
    
    
    @IBAction func saveTask(_ sender: UIButton) {
        // will validate textfields and will call the update function if succesfull
        if(labelTaskName.text == "" || labelAssessmentName.text == "" || labelDaysTillCompletion.text == "" || labelPercentage.text == ""){
            
            let alert = UIAlertController(title: "Oops", message: "Please fill in all details", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            addTaskValidation()
            let alert = UIAlertController(title: "Success!", message: "Task added!", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            //reset fields
            labelTaskName.text = ""
            labelDaysTillCompletion.text = ""
            labelNotes.text = ""
            labelPercentage.text = ""
            
        }
        
        
    }    
    
}
