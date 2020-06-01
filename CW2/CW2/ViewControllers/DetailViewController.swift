//
//  DetailViewController.swift
//  CW2
//
//  Created by Guest 1 on 25/04/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var tableView: UITableView!
    var currentTask:Tasks?
    //sets the cell colour
    let cellColour:UIColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
    let cellSelectedColour:UIColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //tableView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        configureView()
        
    }
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var formatDate = DateFormatter()
        
        
        //sets the values for the custom cell view display data from the database
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let title = self.fetchedResultsController.fetchedObjects?[indexPath.row].taskName
        let notesCell = self.fetchedResultsController.fetchedObjects?[indexPath.row].notes
        let daysLeftCell = self.fetchedResultsController.fetchedObjects?[indexPath.row].daysTillCompletion
        let dueDateCell = self.fetchedResultsController.fetchedObjects?[indexPath.row]
        let taskProgressGraph = (self.fetchedResultsController.fetchedObjects?[indexPath.row].taskPercentage)!
        
        formatDate.dateFormat = "d MMM yyyy"
        
        cell.taskDueDateCell.text = "Due: " + formatDate.string(from:(dueDateCell?.taskDueDate)!)
        cell.taskNameCell.text = title
        cell.taskNotesCell.text = notesCell
        cell.taskDaysLeftCell.text = daysLeftCell
        cell.taskGraphProgress.setProgressAnimation(duration: 1.0, value: Float(taskProgressGraph/100.0))
        cell.labelPercentage.text = ("\(taskProgressGraph)" + "%")
        self.configureCell(cell, indexPath: indexPath)
        let backgroundView = UIView()
        backgroundView.backgroundColor = cellSelectedColour
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        
        cell.backgroundColor = cellColour
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var assessment: Assessment? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //assigns the values to the full description
        
        
        if let identifier = segue.identifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.currentTask = object
                
            }
            switch identifier
            {
            case "assessmentDetail":
                let destVC = segue.destination as! AssessmentDetailViewController
                
                if let overallData = fetchedResultsController.fetchedObjects {
                    var overallProgression = 0.0
                    var taskAmount = fetchedResultsController.fetchedObjects?.count ?? 0
                    
                    for i in overallData {
                        overallProgression = overallProgression + i.taskPercentage
                    }
                    var totalProgress = overallProgression / Double(taskAmount)
                    destVC.progress = totalProgress
                    
                }
                
                
                if let assessmentName = self.assessment?.assessmentName
                {
                    destVC.assessmentName = assessmentName
                }
                else {
                    destVC.assessmentName = "Assessment"
                }
                
                if let notes = self.assessment?.notes
                {
                    destVC.textNotes = notes
                }
                else {
                    destVC.textNotes = ""
                }
                
                if let value = self.assessment?.value {
                    destVC.assessmentValue = value + "%"
                }
                else {
                    destVC.assessmentValue = "0%"
                }
                if let moduleName = self.assessment?.moduleName {
                    destVC.moduleName = moduleName + " "
                }
                else {
                    destVC.moduleName = "No Module Name"
                }
                if let level = self.assessment?.level {
                    destVC.assessmentLevel = level
                }
                else {
                    destVC.assessmentLevel = "-"
                }
                if let markAwarded = self.assessment?.markAwarded {
                    destVC.assessmentMarkAwarded = markAwarded
                }
                else {
                    destVC.assessmentMarkAwarded = "-"
                }
                if let dueDate = self.assessment?.dueDate {
                    destVC.assessmentDueDate = dueDate
                }
                else {
                    
                }
                
            default:
                break
                
            }
        }
        
        //links the controllers to the segues
        if segue.identifier == "addTask" {
            let object = self.assessment
            let controller = segue.destination as! AddTaskViewController
            controller.assessment = object 
        }
        
        if segue.identifier == "editTask" {
            let destVC = segue.destination as! EditTaskViewController
            destVC.currentTask = self.currentTask
        }
        
    }
    
    
    var _fetchedResultsController: NSFetchedResultsController<Tasks>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Tasks> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        let currentAssessment = self.assessment
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "taskName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if(self.assessment != nil)
        {
            let predicate = NSPredicate(format: "containsAssessment = %@", currentAssessment!)
            fetchRequest.predicate = predicate
        }
        else {
            let predicate = NSPredicate(format: "containsAssessment = %@", "Coursework 2")
            fetchRequest.predicate = predicate
        }
        
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController<Tasks>(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: #keyPath(Tasks.assessment),
            cacheName: nil)
        
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = assessment {
            if let label = detailDescriptionLabel {
                label.text = detail.assessmentName
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
        case .move:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

