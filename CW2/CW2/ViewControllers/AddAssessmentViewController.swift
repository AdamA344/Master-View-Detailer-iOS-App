//
//  AddAssessmentViewController.swift
//  CW2
//
//  Created by Guest 1 on 19/05/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class AddAssessmentViewController: UIViewController {
    
    
    @IBOutlet weak var moduleNameText: UITextField!
    @IBOutlet weak var assessmentNameText: UITextField!
    @IBOutlet weak var valueText: UITextField!
    @IBOutlet weak var resultText: UITextField!
    @IBOutlet weak var notesText: UITextField!
    @IBOutlet weak var levelText: UITextField!
    @IBOutlet weak var dueDateValue: UIDatePicker!
    @IBOutlet weak var addToCalendar: UISwitch!
    
    let defaults = UserDefaults.standard
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //data persistance
        let saveSelector = #selector(saveTextFields)
        let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: saveSelector, name: UIApplication.willResignActiveNotification, object: nil)
        
        let mNT = defaults.string(forKey: "assessmentModuleName")
        let aNT = defaults.string(forKey: "assessmentName")
        let vT = defaults.string(forKey: "assessmentValue")
        let mAT = defaults.string(forKey: "assessmentMarksAwarded")
        let nT = defaults.string(forKey: "assessmentNotes")
        let lT = defaults.string(forKey: "assessmentLevel")
        
        self.moduleNameText.text = mNT
        self.assessmentNameText.text = aNT
        self.valueText.text = vT
        self.resultText.text = mAT
        self.notesText.text = nT
        self.levelText.text = lT
    }
    
    @objc func saveTextFields(){
        defaults.set(self.moduleNameText.text, forKey: "assessmentModuleName")
        defaults.set(self.assessmentNameText.text, forKey: "assessmentName")
        defaults.set(self.valueText.text, forKey: "assessmentValue")
        defaults.set(self.resultText.text, forKey: "assessmentMarksAwarded")
        defaults.set(self.notesText.text, forKey: "assessmentNotes")
        defaults.set(self.levelText.text, forKey: "assessmentLevel")
    }
    
    
    @IBAction func saveAssessmentButton(_ sender: UIButton) {
        // will validate textfields and will call the update function if succesfull
        if(assessmentNameText.text == "" || moduleNameText.text == "" || levelText.text == "" || valueText.text == "" ){
            
            let alert = UIAlertController(title: "Oops", message: "Please fill in all details", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            saveAssessmentValidation()
            let alert = UIAlertController(title: "Success!", message: "Assessment Updated!", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
            
            //resets textfields 
            moduleNameText.text = ""
            assessmentNameText.text = ""
            valueText.text = ""
            resultText.text = ""
            notesText.text = ""
            levelText.text = ""
            
        }
    }
    
    
    func saveAssessmentValidation() {
        // updates the database with the new data from the textfields
        let newAssessment = Assessment(context: context)
        if self.assessmentNameText.text != ""
        {
            newAssessment.assessmentName = self.assessmentNameText.text
            newAssessment.moduleName = self.moduleNameText.text
            newAssessment.notes = self.notesText.text
            newAssessment.level = self.levelText.text
            newAssessment.value = self.valueText.text
            newAssessment.markAwarded = self.resultText.text
            newAssessment.dueDate = self.dueDateValue.date
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        }
        
        // adds the Assessment to the calender
        if addToCalendar.isOn
        {
            let eventStore : EKEventStore = EKEventStore()
            //this is how you set up access for the reminders - extra task
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
                    
                    event.title = newAssessment.assessmentName
                    event.startDate = newAssessment.dueDate
                    event.endDate = newAssessment.dueDate
                    event.notes = newAssessment.notes
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
}
