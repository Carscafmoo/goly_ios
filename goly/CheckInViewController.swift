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
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var yesImageView: UIImageView!
    @IBOutlet weak var noImageView: UIImageView!
    
    let valuePickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let goal = goal {
            presentCorrectView(goal)
            navigationItem.title = goal.name
            promptLabel.text = goal.prompt
        }
        
        valueField.delegate = self
        
        // Populate allowable #'s for the value view:
        let smallNumbers = Array(0...20)
        let mediumNumbers = Array(25...100).filter { (x) in x % 5 == 0 }
        let largeNumbers = Array(150 ... 1000).filter { (x) in x % 50 == 0 }
        numbers = smallNumbers + mediumNumbers + largeNumbers
        
        valuePickerView.delegate = self
        valueField.inputView = valuePickerView
    
        allowSave()
    }
    
    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController!.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let date = datePicker.date
            if let value = valueField.text, intVal = Int(value), goal = goal  {
                goal.checkIn(intVal, date: date)
            }
        }
    }
    
    // MARK: text field
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == "") {
            textField.text = String(numbers[valuePickerView.selectedRowInComponent(0)])
        } else {
            if let index = numbers.indexOf(Int(textField.text!)!) {
                valuePickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the keyboard
        
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
        
        allowSave() // Do this after updatePrompt so it takes into account the prompt value
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
            saveButton.enabled = true
            saveButton.tintColor = nil
        }
    }
    
    func allowSave() {
        saveButton.enabled = false
        if let text = valueField.text {
            if (!text.isEmpty) { saveButton.enabled = true }
        }
    }
    
    func checkInBinary(did: Bool) {
        let val = did ? 1 : 0
        if let goal = goal {
            goal.checkIn(val, date: datePicker.date)
        }
        
        self.performSegueWithIdentifier("checkInBinary", sender: self)
    }
}
