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
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedGoals  = loadGoals() {
            goals += savedGoals
        }
        
        navigationItem.leftBarButtonItem = editButtonItem
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US") // @TODO: Probably figure out where the user is?
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (goals.isEmpty) {
            let alert = UIAlertController(title: "You have no saved goals!", message: "Click the + in the upper right to create a new goal", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        // Always reload the data when the table appears -- you can get here in a variety of ways so it's weird to e.g. check-in then not see that on your screen
        self.tableView.reloadData()
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalTableViewCell", for: indexPath) as! GoalTableViewCell
        let goal = goals[indexPath.row]
        
        cell.nameLabel.text = goal.name
        var dateString = "No Check-Ins"
        if let cit = goal.lastCheckInTime() {
            dateString = "Last Check-In: " + dateFormatter.string(from: cit as Date)
        }
        
        cell.lastCheckInLabel.text = dateString
        cell.checkInButton.goal = goal
        cell.historyButton.goal = goal
        
        let cp = String(goal.currentProgress())
        let fnoun = Frequency.thisNounify(goal.frequency)
        cell.currentProgressLabel.text = cp + " of " + String(goal.target) + " " + fnoun
        
        if (!goal.active) {
            cell.nameLabel.textColor = UIColor.gray
            cell.currentProgressLabel.textColor = UIColor.gray
            cell.lastCheckInLabel.textColor = UIColor.gray
            cell.checkInButton.isEnabled = false
        } else {
            cell.nameLabel.textColor = UIColor.black
            cell.currentProgressLabel.textColor = UIColor.black
            cell.lastCheckInLabel.textColor = UIColor.black
            cell.checkInButton.isEnabled = true
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            goals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveGoals()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let goalViewController = segue.destination as! GoalViewController
            if let selectedGoalItem = sender as? GoalTableViewCell {
                let indexPath = tableView.indexPath(for: selectedGoalItem)!
                let selectedGoal = goals[indexPath.row]
                goalViewController.goal = selectedGoal
            }
        } else if segue.identifier == "AddGoal" {
        } else if segue.identifier == "CheckIn" {
            let checkInController = segue.destination as! CheckInViewController
            if let selectedButton = sender as? goalButton {
                checkInController.goal = selectedButton.goal!
            }
        } else if segue.identifier == "ShowHistory" {
            let historyController = segue.destination as! HistoryViewController
            if let selectedButton = sender as? goalButton {
                historyController.goal = selectedButton.goal!
            }
        } else {
            print("Unrecognized identifier " + (segue.identifier ?? ""))
        }
    }
    
    @IBAction func unwindToGoalList(_ sender: UIStoryboardSegue) {
        if let sourceController = sender.source as? GoalViewController, let goal = sourceController.goal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                goals[selectedIndexPath.row] = goal
            } else {
                goals.append(goal)
            }
            
            goals = Goal.sortGoals(goals)
            
            saveGoals()
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
