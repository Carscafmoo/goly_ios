//
//  GoalTableViewController.swift
//  goly
//
//  Created by Carson Moore on 4/1/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit

class GoalTableViewController: UITableViewController {
    // MARK: Properties
    var goals = [Goal]()
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedGoals  = loadGoals() {
            if (savedGoals.isEmpty) {
                loadSampleGoals() // @TODO: Get rid of this eventually, probably!
            } else {
                goals += savedGoals
            }
        } else {
            loadSampleGoals()
        }
        
        navigationItem.leftBarButtonItem = editButtonItem()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // @TODO: Probably figure out where the user is?
    }
    
    // MARK: Table data source population
    func loadSampleGoals() {
        goals.append(Goal(name: "Test Goal", prompt: "How many 75-minute chunks did you work on Goaly today?", frequency: Frequency.Weekly, target: 5, type: Type.Numeric, checkInFrequency: Frequency.Daily)!)
        goals.append(Goal(name: "Test Goal 2", prompt: "Did you work out today?", frequency: Frequency.Weekly, target: 5, type: Type.Binary, checkInFrequency: Frequency.Daily)!)
        goals.append(Goal(name: "Test Goal 3", prompt: "Did you do heroin today?", frequency: Frequency.Daily, target: 0, type: Type.Binary, checkInFrequency: Frequency.Daily)!)
    }
    
    // MARK: Standard table view definitions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GoalTableViewCell", forIndexPath: indexPath) as! GoalTableViewCell
        let goal = goals[indexPath.row]
        
        cell.nameLabel.text = goal.name
        cell.promptLabel.text = goal.prompt
        var dateString = "No Check-Ins"
        if let cit = goal.lastCheckInTime() {
            dateString = "Last Check-In: " + dateFormatter.stringFromDate(cit)
        }
        
        cell.lastCheckInLabel.text = dateString
        cell.checkInButton.goal = goal
        
        if (!goal.active) {
            cell.nameLabel.textColor = UIColor.grayColor()
            cell.promptLabel.textColor = UIColor.grayColor()
            cell.lastCheckInLabel.textColor = UIColor.grayColor()
            cell.checkInButton.enabled = false
        } else {
            cell.nameLabel.textColor = UIColor.blackColor()
            cell.promptLabel.textColor = UIColor.blackColor()
            cell.lastCheckInLabel.textColor = UIColor.blackColor()
            cell.checkInButton.enabled = true
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            goals.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            saveGoals()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let goalViewController = segue.destinationViewController as! GoalViewController
            if let selectedGoalItem = sender as? GoalTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedGoalItem)!
                let selectedGoal = goals[indexPath.row]
                goalViewController.goal = selectedGoal
            }
        } else if segue.identifier == "AddGoal" {
        } else if segue.identifier == "CheckIn" {
            let checkInController = segue.destinationViewController as! CheckInViewController
            if let selectedButton = sender as? CheckInUIButton {
                checkInController.goal = selectedButton.goal!
            }
        } else {
            print("Unrecognized identifier " + (segue.identifier ?? ""))
        }
    }
    
    @IBAction func unwindToGoalList(sender: UIStoryboardSegue) {
        if let sourceController = sender.sourceViewController as? GoalViewController, goal = sourceController.goal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                goals[selectedIndexPath.row] = goal
            } else {
                goals.append(goal)
            }
            
            goals = sortGoals(goals)
            saveGoals()
            self.tableView.reloadData() // We have to reload the whole shabang after any changes to maintain sorting
        }
        
        if let sourceController = sender.sourceViewController as? CheckInViewController, goal = sourceController.goal {
            // Need to figure out which goal to replace...
            var indexPath: NSIndexPath?
            for (index, _goal) in goals.enumerate() {
                if (_goal.name == goal.name) {
                    goals[index] = goal
                    indexPath = NSIndexPath(forRow: index, inSection: 0)
                }
            }
            
            saveGoals()
            if let ind = indexPath {
                tableView.reloadRowsAtIndexPaths([ind], withRowAnimation: .None)
            }
        }
    }
    
    // MARK: Persistence
    func saveGoals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(goals, toFile: Goal.ArchiveURL.path!)
        if isSuccessfulSave {
        } else {
            print("Save unsuccessful :-(")
        }
    }

    func loadGoals() -> [Goal]? {
        if let goals = NSKeyedUnarchiver.unarchiveObjectWithFile(Goal.ArchiveURL.path!) as? [Goal] {
            return sortGoals(goals)
        }
        
        return nil
    }
    
    func sortGoals(goals: [Goal]) -> [Goal] {
        return goals.sort {
            if ($0.active && !$1.active) { return true; } // active always comes first
            if (!$0.active && $1.active) { return false; }
            
            // That which is more frequently checked in should come first
            if ($0.checkInFrequency.hashValue < $1.checkInFrequency.hashValue) { return true; }
            if ($0.checkInFrequency.hashValue > $1.checkInFrequency.hashValue) { return false; }
            
            // Otherwise, sort by name I guess
            return $0.name < $1.name
        }
    }
    
}
