//
//  CheckInViewController.swift
//  goly
//
//  Created by Carson Moore on 4/9/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//
import UIKit
class CheckInViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate { //, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    var goal: Goal?
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var yesImageView: UIImageView!
    @IBOutlet weak var noImageView: UIImageView!
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()

    var date: Date? // Allow us to pass in a date prior to loading if we want
    var currentTextField: UITextField?
    var originalPoint: CGPoint?

    var originalYesImageFrame: CGRect?
    var originalNoImageFrame: CGRect?
    var autoPopKeyboard = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if date == nil {
            date = Date()
        }

        if let goal = goal {
            presentCorrectView(goal)
            navigationItem.title = goal.name
            promptLabel.text = goal.prompt
            
            // If there is a check-in for the current timeframe, go ahead and grab it and display that value:
            if let checkIn = goal.getCheckInForDate(date!) {
                valueField.text = String(checkIn.value)
            }

            dateField.text = goal.getCheckInTimeframeForDate(date: date!).toString()
        }
        
        valueField.delegate = self
        valueField.keyboardType = .numberPad

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US") // @TODO: Probably figure out where the user is?
        
        datePicker.maximumDate = date
        datePicker.datePickerMode = .date
        dateField.delegate = self
        dateField.inputView = datePicker

        datePicker.addTarget(self, action: #selector(datePickerChanged), for: UIControlEvents.valueChanged)
        
        // Set up a change function on the value field:
        valueField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        allowSave()
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if let text = valueField.text, let val = Int(text), let goal = goal {
            goal.checkIn(val, date: datePicker.date)
        }
        
        saveAndPop()
    }
    
    
    func saveAndPop() {
        if var goals = Goal.loadGoals() {
            for (index, _goal) in goals.enumerated() {
                if (_goal.name == goal!.name) {
                    goals[index] = goal!
                }
            }
            
            Goal.saveGoals(goals)
        }

        let nvc = navigationController!
        if let hvc = nvc.viewControllers.suffix(2).first as? HistoryViewController {
            // You need to reload any saved data
            hvc.viewDidLoad()
        }

        nvc.popViewController(animated: false) // This looks terrible with the swipes if it's animated
    }

    
    
    // MARK: text fields
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        if (textField == dateField) { delegateDateFieldDidBeginEditing(textField) }
    }
    
    // Use that textFieldDidChange from earlier
    func textFieldDidChange(_ textField: UITextField) {
        allowSave()
    }
    
    func delegateDateFieldDidBeginEditing(_ textField: UITextField) {
        datePicker.date = date!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the keyboard
        currentTextField = nil
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        allowSave()
    }
    
    // MARK: Date picker view delegate... sort of
    func datePickerChanged(_ datePicker: UIDatePicker) {
        date = datePicker.date
        if let checkIn = goal?.getCheckInForDate(datePicker.date) {
            valueField.text = String(checkIn.value)
        } else {
            valueField.text = ""
        }

        if let checkInTimeframe = goal?.getCheckInTimeframeForDate(date: datePicker.date) {
            dateField.text = checkInTimeframe.toString()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let ctf = currentTextField {
            if (ctf.canResignFirstResponder) { ctf.resignFirstResponder() }
        }
    }
    
    // MARK: Gesture recognizers
    @IBAction func handleYesTap(_ sender: UITapGestureRecognizer) {
        checkInBinary(true)
    }
    
    @IBAction func handleNoTap(_ sender: UITapGestureRecognizer) {
        checkInBinary(false)
    }
    
    // MARK: Swipe gesture recognizer
    // Stolen basically verbatim from http://guti.in/articles/creating-tinder-like-animations/, minus Bar Rafaeli for #sexism purposes
    func handleSwipe(_ sender: UIPanGestureRecognizer) {
        // Parameters for determining swipe strength and rotation, etc
        let strengthPixels = UIScreen.main.bounds.width / 2 // # of pixels that qualifies as a fully-fledged swipe -- half the screen
        let rotationScale = 16 // fraction of a circle you want to rotate the view.  Less is more rotation
        let sizeScaleFactor = 4 // 1 - fraction how quickly you want the view to shrink... i.e., 4 will shrink to 75%, 5 to 80%, 3 to 67%
        let minScale = CGFloat(0.75) // Cap the view shrinkage
        let baseImageAlpha = CGFloat(0.5) // We scale up and down the image alphas for yes and now depending on the swipe strength in their respective direction
        
        
        let xDistance = sender.translation(in: self.view).x
        let yDistance = sender.translation(in: self.view).y
        
        switch (sender.state) {
        case .began:
            self.originalPoint = self.view.center;
            self.originalYesImageFrame = yesImageView.frame
            self.originalNoImageFrame = noImageView.frame
            
        case .changed:
            let rotationStrength = max(min(xDistance / strengthPixels, 1.0), -1.0)
            let rotationAngle = (2 * Double.pi * Double(rotationStrength) / Double(rotationScale))
            let scaleStrength = 1 - fabs(rotationStrength) / CGFloat(sizeScaleFactor)
            let scale = max(scaleStrength, minScale)
            self.view.center = CGPoint(x: self.originalPoint!.x + xDistance, y: self.originalPoint!.y + yDistance)
            let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale)) // scale x and y equally I guess
            self.view.transform = scaleTransform
            
            // Image alphas
            let alphaScale = (1 - baseImageAlpha) * rotationStrength // Rotation strength is negative if swiping left so we don't need to if on that
            yesImageView.alpha = CGFloat(baseImageAlpha + alphaScale)
            noImageView.alpha = CGFloat(baseImageAlpha - alphaScale)
            
            // Move images -- they both end up on the edge of the page, offset by about 8
            // Depends on if we're swiping left or right whether we'll want to track min or max X value
            if (xDistance < 0) {
                let frameWidth = UIScreen.main.bounds.width
                let originalYesDistance = frameWidth - originalYesImageFrame!.maxX - 8
                let yesDistanceToTranslate = originalYesDistance * fabs(CGFloat(rotationStrength))
                yesImageView.transform = CGAffineTransform(translationX: yesDistanceToTranslate, y: CGFloat(0.0))
                
                let originalNoDistance = frameWidth - originalNoImageFrame!.maxX - 8
                let noDistanceToTranslate = originalNoDistance * fabs(CGFloat(rotationStrength))
                noImageView.transform = CGAffineTransform(translationX: noDistanceToTranslate, y: CGFloat(0.0))
            } else {
                let originalYesDistance = originalYesImageFrame!.minX - 8
                let yesDistanceToTranslate = originalYesDistance * fabs(CGFloat(rotationStrength))
                yesImageView.transform = CGAffineTransform(translationX: -yesDistanceToTranslate, y: CGFloat(0.0))
                
                let originalNoDistance = originalNoImageFrame!.minX - 8
                let noDistanceToTranslate = originalNoDistance * fabs(CGFloat(rotationStrength))
                noImageView.transform = CGAffineTransform(translationX: -noDistanceToTranslate, y: CGFloat(0.0))
            }
            
        case .ended:
            self.handleSwipeEnd(xDistance)
        default:
            break
        }
    }
    
    func handleSwipeEnd(_ swipeDistance: CGFloat) {
        let swipeMax = UIScreen.main.bounds.width / 2 // You must swipe at least 320 pixels for it to register as a swipe
        
        if (fabs(swipeDistance) >= CGFloat(swipeMax)) {
            if (swipeDistance > 0) { checkInBinary(true) }
            else { checkInBinary(false) }
            
            return
        }
        
        // Otherwise snap back
        UIView.animate(withDuration: 0.2, animations: {
            self.view.center = self.originalPoint!
            self.view.transform = CGAffineTransform(rotationAngle: 0)
            self.yesImageView.alpha = CGFloat(1.0)
            self.noImageView.alpha = CGFloat(1.0)
            self.yesImageView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.noImageView.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: nil)
    }
    
    // MARK: Helpers
    func presentCorrectView(_ goal: Goal) {
        switch goal.type {
        case .Binary:
            yesImageView.isHidden = false
            noImageView.isHidden = false
            valueField.isHidden = true

            // You can't hide a menu button but you can disable it and and make it disappear
            saveButton.tintColor = UIColor.clear
            saveButton.isEnabled = false
            
            // Swipe recognizers
            let swipeRight = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe))
            // swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            self.view.addGestureRecognizer(swipeRight)
            
            // let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            // swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            // self.view.addGestureRecognizer(swipeLeft)
            
            
        case .Numeric:
            yesImageView.isHidden = true
            noImageView.isHidden = true
            valueField.isHidden = false
            
            saveButton.isEnabled = true
            saveButton.tintColor = nil
            if autoPopKeyboard {
                valueField.becomeFirstResponder()
            }
        }
    }
    
    func allowSave() {
        saveButton.isEnabled = false
        if let text = valueField.text, let _ = date {
            if (!text.isEmpty) { saveButton.isEnabled = true }
        }
    }
    
    func checkInBinary(_ did: Bool) {
        let val = did ? 1 : 0
        if let goal = goal {
            goal.checkIn(val, date: datePicker.date)
        }
        
        saveAndPop()
    }
}
