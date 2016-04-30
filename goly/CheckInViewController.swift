//
//  CheckInViewController.swift
//  goly
//
//  Created by Carson Moore on 4/9/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//
import UIKit
class CheckInViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    var goal: Goal?
    var numbers = [Int]()
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var yesImageView: UIImageView!
    @IBOutlet weak var noImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    let datePicker = UIDatePicker()
    let valuePickerView = UIPickerView()
    let dateFormatter = NSDateFormatter()
    
    var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSDate()
        if let goal = goal {
            presentCorrectView(goal)
            navigationItem.title = goal.name
            promptLabel.text = goal.prompt
            
            // If there is a check-in for the current timeframe, go ahead and grab it and display that value:
            if let checkIn = goal.getCheckInForDate(date) {
                valueField.text = String(checkIn.value)
            }
            
        }
        
        valueField.delegate = self
        
        // Populate allowable #'s for the value view:
        let smallNumbers = Array(0...20)
        let mediumNumbers = Array(25...100).filter { (x) in x % 5 == 0 }
        let largeNumbers = Array(150 ... 1000).filter { (x) in x % 50 == 0 }
        numbers = smallNumbers + mediumNumbers + largeNumbers
        
        valuePickerView.delegate = self
        valueField.inputView = valuePickerView
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // @TODO: Probably figure out where the user is?
        
        datePicker.maximumDate = date
        datePicker.datePickerMode = .Date
        dateField.delegate = self
        dateField.inputView = datePicker
        dateField.text = dateFormatter.stringFromDate(NSDate())
        datePicker.addTarget(self, action: #selector(datePickerChanged), forControlEvents: UIControlEvents.ValueChanged)
        
        allowSave()
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        if let text = valueField.text, val = Int(text), goal = goal {
            goal.checkIn(val, date: datePicker.date)
        }
        
        saveAndPop()
    }
    
    
    func saveAndPop() {
        if var goals = Goal.loadGoals() {
            for (index, _goal) in goals.enumerate() {
                if (_goal.name == goal!.name) {
                    goals[index] = goal!
                }
            }
            
            Goal.saveGoals(goals)
        }
        
        // If you are the last dude in the stack, tell the table to reload its data:
        if (navigationController!.viewControllers.count == 2) {
            if let cnt = navigationController!.viewControllers[0] as? GoalTableViewController {
                cnt.tableView.reloadData()
            }
        }
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    // MARK: text fields
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
        if (textField == valueField) { delegateValueFieldDidBeginEditing(textField) }
        else if (textField == dateField) { delegateDateFieldDidBeginEditing(textField) }
        
    }
    
    func delegateValueFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == "") {
            valuePickerView.selectRow(0, inComponent: 0, animated: false) // reset to 0
            textField.text = String(numbers[valuePickerView.selectedRowInComponent(0)])
        } else {
            if let index = numbers.indexOf(Int(textField.text!)!) {
                valuePickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    func delegateDateFieldDidBeginEditing(textField: UITextField) {
        if let text = textField.text, date = dateFormatter.dateFromString(text) {
            datePicker.date = date
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the keyboard
        currentTextField = nil
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        allowSave()
    }
    
    // MARK: Picker View DS
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == valuePickerView) {
            return numbers.count
        } else {
            return 0 // should never hit this
        }
    }
    
    // MARK: Picker view delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == valuePickerView) {
            return String(numbers[row])
        } else {
            return "" // and here again we should never hit this
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == valuePickerView) {
            valueField.text = String(numbers[row])
        }
        
        allowSave()
    }
    
    // MARK: Date picker view delegate... sort of
    func datePickerChanged(datePicker: UIDatePicker) {
        dateField.text = dateFormatter.stringFromDate(datePicker.date)
        if let checkIn = goal?.getCheckInForDate(datePicker.date) {
            valueField.text = String(checkIn.value)
        } else {
            valueField.text = ""
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let ctf = currentTextField {
            if (ctf.canResignFirstResponder()) { ctf.resignFirstResponder() }
        }
    }
    
    // MARK: Gesture recognizers
    @IBAction func handleYesTap(sender: UITapGestureRecognizer) {
        checkInBinary(true)
    }
    
    @IBAction func handleNoTap(sender: UITapGestureRecognizer) {
        checkInBinary(false)
    }

    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            checkInBinary(true)
        case UISwipeGestureRecognizerDirection.Left:
            checkInBinary(false)
        default:
            break
        }
    }
    
    // MARK: Helpers
    func presentCorrectView(goal: Goal) {
        switch goal.type {
        case .Binary:
            yesImageView.hidden = false
            noImageView.hidden = false
            valueField.hidden = true
            valueLabel.hidden = true
            // You can't hide a menu button but you can disable it and and make it disappear
            saveButton.tintColor = UIColor.clearColor()
            saveButton.enabled = false
            
            // Swipe recognizers
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.view.addGestureRecognizer(swipeLeft)
            
            
        case .Numeric:
            yesImageView.hidden = true
            noImageView.hidden = true
            valueField.hidden = false
            valueLabel.hidden = false
            saveButton.enabled = true
            saveButton.tintColor = nil
        }
    }
    
    func allowSave() {
        saveButton.enabled = false
        if let text = valueField.text, dateText = dateField.text, _ = dateFormatter.dateFromString(dateText) {
            if (!text.isEmpty) { saveButton.enabled = true }
        }
    }
    
    func checkInBinary(did: Bool) {
        let val = did ? 1 : 0
        if let goal = goal {
            goal.checkIn(val, date: datePicker.date)
        }
        
        saveAndPop()
    }
}
