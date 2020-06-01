//
//  EditTaskViewController.swift
//  CW2
//
//  Created by Guest 1 on 28/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI

class EditTaskViewController: UIViewController {
    
    @IBOutlet weak var textTaskName: UITextField!
    @IBOutlet weak var textAssessmentName: UITextField!
    @IBOutlet weak var textStartDate: UIDatePicker!
    @IBOutlet weak var textDueDate: UIDatePicker!
    @IBOutlet weak var textDayTillCompletion: UITextField!
    @IBOutlet weak var textNotes: UITextField!
    @IBOutlet weak var textAddToCalender: UISwitch!
    @IBOutlet weak var textPercentage: UITextField!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var currentTask:Tasks?
    var editPercentage = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //populates labels with data from database of the selected cell
        textTaskName.text = currentTask?.taskName
        textAssessmentName.text = currentTask?.assessment
        textStartDate.date = currentTask?.startDate! as! Date
        textDueDate.date = currentTask?.taskDueDate! as! Date
        textDayTillCompletion.text = currentTask?.daysTillCompletion
        textNotes.text = currentTask?.notes
        editPercentage = currentTask?.taskPercentage ?? 0 
        let stringConversion = String(editPercentage)
        textPercentage.text = stringConversion
    }
    
    
    func updateTaskValidation(){
        // updates the database with the new data from the textfields 
        currentTask?.assessment = textAssessmentName.text
        currentTask?.taskName = textTaskName.text
        currentTask?.notes = textNotes.text
        currentTask?.startDate = textStartDate.date
        currentTask?.taskDueDate = textDueDate.date
        currentTask?.daysTillCompletion = textDayTillCompletion.text
        currentTask?.taskPercentage = Double(textPercentage.text ?? "") ?? 0
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        // gives application access to push data to the calender app
        if textAddToCalender.isOn
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
                    //calender will display this information
                    event.title = self.currentTask?.taskName
                    event.startDate = self.currentTask?.startDate
                    event.endDate = self.currentTask?.taskDueDate
                    event.notes = self.currentTask?.notes
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
    
    @IBAction func updateTask(_ sender: UIButton) {
        // will validate textfields and will call the update function if succesfull
        if(textTaskName.text == "" || textAssessmentName.text == "" || textDayTillCompletion.text == ""){
            
            let alert = UIAlertController(title: "Oops", message: "Please fill in all details", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            updateTaskValidation()
            let alert = UIAlertController(title: "Success!", message: "Task Updated!", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
