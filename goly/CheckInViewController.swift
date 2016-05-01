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
    var originalPoint: CGPoint?
    
    var originalYesImageFrame: CGRect?
    var originalNoImageFrame: CGRect?
    
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
        
        navigationController!.popViewControllerAnimated(false) // This looks terrible with the swipes if it's animated
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
    
    // MARK: Swipe gesture recognizer
    // Stolen basically verbatim from http://guti.in/articles/creating-tinder-like-animations/, minus Bar Rafaeli for #sexism purposes
    func handleSwipe(sender: UIPanGestureRecognizer) {
        // Parameters for determining swipe strength and rotation, etc
        let strengthPixels = 240.0 // # of pixels that qualifies as a fully-fledged swipe
        let rotationScale = 16 // fraction of a circle you want to rotate the view.  Less is more rotation
        let sizeScaleFactor = 4 // 1 - fraction how quickly you want the view to shrink... i.e., 4 will shrink to 75%, 5 to 80%, 3 to 67%
        let minScale = 0.75 // Cap the view shrinkage
        let baseImageAlpha = 0.5 // We scale up and down the image alphas for yes and now depending on the swipe strength in their respective direction
        
        
        let xDistance = sender.translationInView(self.view).x
        let yDistance = sender.translationInView(self.view).y
        
        switch (sender.state) {
        case .Began:
            self.originalPoint = self.view.center;
            self.originalYesImageFrame = yesImageView.frame
            self.originalNoImageFrame = noImageView.frame
            
        case .Changed:
            let rotationStrength = max(min(Double(xDistance) / strengthPixels, 1.0), -1.0)
            let rotationAngle = (2 * M_PI * rotationStrength / Double(rotationScale))
            let scaleStrength = 1 - fabs(rotationStrength) / Double(sizeScaleFactor)
            let scale = max(scaleStrength, minScale)
            self.view.center = CGPointMake(self.originalPoint!.x + xDistance, self.originalPoint!.y + yDistance)
            let transform = CGAffineTransformMakeRotation(CGFloat(rotationAngle))
            let scaleTransform = CGAffineTransformScale(transform, CGFloat(scale), CGFloat(scale)) // scale x and y equally I guess
            self.view.transform = scaleTransform
            
            // Image alphas
            let alphaScale = (1 - baseImageAlpha) * rotationStrength // Rotation strength is negative if swiping left so we don't need to if on that
            yesImageView.alpha = CGFloat(baseImageAlpha + alphaScale)
            noImageView.alpha = CGFloat(baseImageAlpha - alphaScale)
            
            // Move images -- they both end up on the edge of the page, offset by about 8
            // Depends on if we're swiping left or right whether we'll want to track min or max X value
            if (xDistance < 0) {
                let frameWidth = UIScreen.mainScreen().bounds.width
                let originalYesDistance = frameWidth - originalYesImageFrame!.maxX - 8
                let yesDistanceToTranslate = originalYesDistance * fabs(CGFloat(rotationStrength))
                yesImageView.transform = CGAffineTransformMakeTranslation(yesDistanceToTranslate, CGFloat(0.0))
                
                let originalNoDistance = frameWidth - originalNoImageFrame!.maxX - 8
                let noDistanceToTranslate = originalNoDistance * fabs(CGFloat(rotationStrength))
                noImageView.transform = CGAffineTransformMakeTranslation(noDistanceToTranslate, CGFloat(0.0))
            } else {
                let originalYesDistance = originalYesImageFrame!.minX - 8
                let yesDistanceToTranslate = originalYesDistance * fabs(CGFloat(rotationStrength))
                yesImageView.transform = CGAffineTransformMakeTranslation(-yesDistanceToTranslate, CGFloat(0.0))
                
                let originalNoDistance = originalNoImageFrame!.minX - 8
                let noDistanceToTranslate = originalNoDistance * fabs(CGFloat(rotationStrength))
                noImageView.transform = CGAffineTransformMakeTranslation(-noDistanceToTranslate, CGFloat(0.0))
            }
            
        case .Ended:
            self.handleSwipeEnd(xDistance)
        default:
            break
        }
    }
    
    func handleSwipeEnd(swipeDistance: CGFloat) {
        let swipeMax = 240.0 // You must swipe at least 320 pixels for it to register as a swipe
        
        if (fabs(swipeDistance) >= CGFloat(swipeMax)) {
            if (swipeDistance > 0) { checkInBinary(true) }
            else { checkInBinary(false) }
            
            return
        }
        
        // Otherwise snap back
        UIView.animateWithDuration(0.2, animations: {
            self.view.center = self.originalPoint!
            self.view.transform = CGAffineTransformMakeRotation(0)
            self.yesImageView.alpha = CGFloat(1.0)
            self.noImageView.alpha = CGFloat(1.0)
            self.yesImageView.transform = CGAffineTransformMakeTranslation(0, 0)
            self.noImageView.transform = CGAffineTransformMakeTranslation(0, 0)
            
        }, completion: nil)
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
            let swipeRight = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe))
            // swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(swipeRight)
            
            // let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            // swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            // self.view.addGestureRecognizer(swipeLeft)
            
            
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
