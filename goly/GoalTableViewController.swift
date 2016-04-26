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
            goals += savedGoals
        }
        
        navigationItem.leftBarButtonItem = editButtonItem()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // @TODO: Probably figure out where the user is?
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (goals.isEmpty) {
            let alert = UIAlertController(title: "You have no saved goals!", message: "Click the + in the upper right to create a new goal", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Table data source population
    func loadSampleGoals() {
        self.goals = GoalGenerator().getSampleGoals()
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
        var dateString = "No Check-Ins"
        if let cit = goal.lastCheckInTime() {
            dateString = "Last Check-In: " + dateFormatter.stringFromDate(cit)
        }
        
        cell.lastCheckInLabel.text = dateString
        cell.checkInButton.goal = goal
        cell.historyButton.goal = goal
        
        let cp = String(goal.currentProgress())
        let fnoun = Frequency.thisNounify(goal.frequency)
        cell.currentProgressLabel.text = cp + " of " + String(goal.target) + " " + fnoun
        
        if (!goal.active) {
            cell.nameLabel.textColor = UIColor.grayColor()
            cell.currentProgressLabel.textColor = UIColor.grayColor()
            cell.lastCheckInLabel.textColor = UIColor.grayColor()
            cell.checkInButton.enabled = false
        } else {
            cell.nameLabel.textColor = UIColor.blackColor()
            cell.currentProgressLabel.textColor = UIColor.blackColor()
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
            if let selectedButton = sender as? goalButton {
                checkInController.goal = selectedButton.goal!
            }
        } else if segue.identifier == "ShowHistory" {
            let historyController = segue.destinationViewController as! HistoryViewController
            if let selectedButton = sender as? goalButton {
                historyController.goal = selectedButton.goal!
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
            
            goals = Goal.sortGoals(goals)
            
            saveGoals()
            self.tableView.reloadData() // We have to reload the whole shabang after any changes to maintain sorting
        }
    }
    
    // MARK: Persistence
    func saveGoals() {
        Goal.saveGoals(goals)
    }

    func loadGoals() -> [Goal]? {
        return Goal.loadGoals()
    }
}
