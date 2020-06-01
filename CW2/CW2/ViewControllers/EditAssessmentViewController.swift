//
//  EditAssessmentViewController.swift
//  CW2
//
//  Created by Guest 1 on 26/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit
import CoreData
import EventKit
import EventKitUI

class EditAssessmentViewController: UIViewController {
    var currentAssessment:Assessment?
    @IBOutlet weak var textModuleName: UITextField!
    @IBOutlet weak var textAssessmentName: UITextField!
    @IBOutlet weak var textAssessmentValue: UITextField!
    @IBOutlet weak var textAssessmentMarkAwarded: UITextField!
    @IBOutlet weak var textAssessmentLevel: UITextField!
    @IBOutlet weak var textAssessmentNotes: UITextField!
    @IBOutlet weak var textAssessmentDueDate: UIDatePicker!
    @IBOutlet weak var updateCalender: UISwitch!
    @IBOutlet weak var updateAssessmentCal: UISwitch!
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        //populates labels with data from database of the selected cell
        textAssessmentName.text = currentAssessment?.assessmentName
        textModuleName.text = currentAssessment?.moduleName
        textAssessmentValue.text = currentAssessment?.value
        textAssessmentMarkAwarded.text = currentAssessment?.markAwarded
        textAssessmentLevel.text = currentAssessment?.level
        textAssessmentNotes.text = currentAssessment?.notes
        textAssessmentDueDate.date = currentAssessment?.dueDate! as! Date
        
    }
    
    func updateAssessment() {
        // updates the database with the new data from the textfields
        currentAssessment?.assessmentName = textAssessmentName.text
        currentAssessment?.moduleName = textModuleName.text
        currentAssessment?.value = textAssessmentValue.text
        currentAssessment?.markAwarded = textAssessmentMarkAwarded.text
        currentAssessment?.level = textAssessmentLevel.text
        currentAssessment?.notes = textAssessmentNotes.text
        currentAssessment?.dueDate = textAssessmentDueDate.date
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        // adds the Assessment to the calender 
        if updateAssessmentCal.isOn
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
                    event.title = self.currentAssessment?.assessmentName
                    event.endDate = self.currentAssessment?.dueDate
                    event.notes = self.currentAssessment?.notes
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
    
    @IBAction func updateAssessment(_ sender: UIButton) {
        // will validate textfields and will call the update function if succesfull
        if(textAssessmentName.text == "" || textModuleName.text == "" || textAssessmentValue.text == "" || textAssessmentLevel.text == "" ){
            
            let alert = UIAlertController(title: "Oops", message: "Please fill in all details", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            updateAssessment()
            let alert = UIAlertController(title: "Success!", message: "Assessment Saved", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        //resets textfields
        textAssessmentName.text = ""
        textModuleName.text = ""
        textAssessmentValue.text = ""
        textAssessmentMarkAwarded.text = ""
        textAssessmentLevel.text = ""
        textAssessmentNotes.text = ""
        
    }
    
    
    
}
