//
//  ViewController.swift
//  goly
//
//  Created by Carson Moore on 3/19/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var checkInTextField: UITextField!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nameDetail: UILabel!
    @IBOutlet weak var frequencyDetail: UILabel!
    @IBOutlet weak var typeDetail: UILabel!
    @IBOutlet weak var targetDetail: UILabel!
    @IBOutlet weak var checkInDetail: UILabel!
    @IBOutlet weak var promptDetail: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Picker views
    // Open question -- better to have one PV that responds differently depending on what FR is?
    // Or better to have several, distinct PVs?  I went with latter for easiness of if statements in 
    // delegate fxns
    let frequencyPickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let targetPickerView = UIPickerView()
    let checkInPickerView = UIPickerView()
    
    // Stuff populating picker view
    var frequencies = [String]()
    var types = [String]()
    var numbers = [Int]()
    
    // Collection of details for easy iteration
    var details = [UILabel]()
    
    // Whether the prompt text field has been manually updated yet
    var disableAutoPrompt: Bool = false
    
    var goal: Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        nameTextField.delegate = self
        promptTextField.delegate = self
        frequencyTextField.delegate = self
        typeTextField.delegate = self
        targetTextField.delegate = self
        checkInTextField.delegate = self
        
        frequencyPickerView.delegate = self
        frequencies = ["Daily", "Weekly", "Monthly", "Quarterly", "Yearly"]
        frequencyTextField.inputView = frequencyPickerView
        
        typePickerView.delegate = self
        types = ["Yes/No", "Numeric"]
        typeTextField.inputView = typePickerView
        
        targetPickerView.delegate = self
        let smallNumbers = Array(0...20)
        let mediumNumbers = Array(25...100).filter { (x) in x % 5 == 0 }
        let largeNumbers = Array(150 ... 1000).filter { (x) in x % 50 == 0 }
        numbers = smallNumbers + mediumNumbers + largeNumbers
        targetTextField.inputView = targetPickerView
        
        checkInPickerView.delegate = self
        // re-use frequencies
        checkInTextField.inputView = checkInPickerView
        
        // Hide all of the details
        details = [nameDetail, frequencyDetail, typeDetail, targetDetail, checkInDetail, promptDetail]
        hideDetails()
        
        // If the goal already exists, prepopulate all its details:
        if let goal = goal {
            nameTextField.text = goal.name
            frequencyTextField.text = goal.frequency.rawValue
            typeTextField.text = goal.type.rawValue
            targetTextField.text = String(goal.target)
            checkInTextField.text = goal.checkInFrequency.rawValue
            promptTextField.text = goal.prompt
            navigationItem.title = goal.name
            activeSwitch.on = goal.active
            
            if (goal.checkIns.count > 0) {
                checkInTextField.enabled = false
                frequencyTextField.enabled = false
            }
        } else {
            activeLabel.hidden = true
            activeSwitch.hidden = true
        }
        
        allowSave() // disable the save button as necessary!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            let name = nameTextField.text ?? ""
            let frequency = Frequency(rawValue: frequencyTextField.text!)!
            let type = Type(rawValue: typeTextField.text!)!
            let target = Int(targetTextField.text!)!
            let cif = Frequency(rawValue: checkInTextField.text!)!
            let prompt = promptTextField.text ?? ""
            let active = activeSwitch.on
            if let goal = goal {
                goal.name = name
                goal.frequency = frequency
                goal.type = type
                goal.target = target
                goal.checkInFrequency = cif
                goal.prompt = prompt
                goal.active = active
                disableAutoPrompt = true
            } else { // it's a new goal
                goal = Goal(name: name, prompt: prompt, frequency: frequency, target: target, type: type, checkInFrequency: cif)
            }
        }
    }
    
    // MARK: text field
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == frequencyTextField) {
            if (textField.text == "") {
                textField.text = frequencies[frequencyPickerView.selectedRowInComponent(0)]
            } else {
                if let index = frequencies.indexOf(textField.text!) {
                    frequencyPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        } else if (textField == typeTextField) {
            if (textField.text == "") {
                textField.text = types[typePickerView.selectedRowInComponent(0)]
            } else {
                if let index = types.indexOf(textField.text!) {
                    typePickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        } else if (textField == targetTextField) {
            if (textField.text == "") {
                textField.text = String(numbers[targetPickerView.selectedRowInComponent(0)])
            } else {
                if let index = numbers.indexOf(Int(textField.text!)!) {
                    targetPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        } else if (textField == checkInTextField) {
            let checkInFrequencies = filterCheckInFrequencies()
            if (textField.text == "") {
                textField.text = checkInFrequencies[checkInPickerView.selectedRowInComponent(0)]
            } else {
                if let index = checkInFrequencies.indexOf(textField.text!) {
                    checkInPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the keyboard
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == nameTextField) {
            navigationItem.title = textField.text
        } else if (textField == promptTextField) {
            disableAutoPrompt = true
        }
        
        updatePrompt() // textFieldDidEndEditing only runs for keyboard inputs and must be run in pickerViews separately
        allowSave() // Do this after updatePrompt so it takes into account the prompt value
    }
    
    // MARK: Picker View DS
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == frequencyPickerView) {
            return frequencies.count
        } else if (pickerView == typePickerView) {
            return types.count
        } else if (pickerView == targetPickerView) {
            return numbers.count
        } else if (pickerView == checkInPickerView) {
            return filterCheckInFrequencies().count
        } else {
            return 0
        }
    }
    
    // MARK: Picker view delegate
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == frequencyPickerView) {
            return frequencies[row]
        } else if (pickerView == typePickerView) {
            return types[row]
        } else if (pickerView == targetPickerView) {
            return String(numbers[row])
        } else if (pickerView == checkInPickerView) {
            return filterCheckInFrequencies()[row]
        } else {
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == frequencyPickerView) {
            frequencyTextField.text = frequencies[row]
            if (!checkInTextField.text!.isEmpty) {
                if let freq = Frequency(rawValue: frequencyTextField.text!), cif = Frequency(rawValue:checkInTextField.text!) {
                    if (!Frequency.conforms(freq, checkInFrequency: cif)) {
                        checkInTextField.text = ""
                    }
                }
            }
        } else if (pickerView == typePickerView) {
            typeTextField.text = types[row]
        } else if (pickerView == targetPickerView) {
            targetTextField.text = String(numbers[row])
        } else if (pickerView == checkInPickerView) {
            checkInTextField.text = filterCheckInFrequencies()[row]
        }
    }
    
    // MARK: Detail disclosures
    @IBAction func discloseNameDetail(sender: UIButton) {
        handleDetailDisclosure(nameDetail)
    }
    
    @IBAction func discloseFrequencyDetail(sender: UIButton) {
        handleDetailDisclosure(frequencyDetail)
    }
    
    @IBAction func discloseTypeDetail(sender: UIButton) {
        handleDetailDisclosure(typeDetail)
    }
    @IBAction func discloseTargetDetail(sender: UIButton) {
        handleDetailDisclosure(targetDetail)
    }
    
    @IBAction func discloseCheckInDetail(sender: UIButton) {
        handleDetailDisclosure(checkInDetail)
    }
    
    @IBAction func disclosePromptDetail(sender: UIButton) {
        handleDetailDisclosure(promptDetail)
    }
    
    // MARK: Helpers
    func filterCheckInFrequencies() -> [String] {
        if let curFreqText = frequencyTextField.text, curFreq = Frequency(rawValue: curFreqText) {
            return frequencies.filter { (x) in Frequency.conforms(curFreq, checkInFrequency: Frequency(rawValue: x)!) }
        } else {
            return frequencies
        }
    }
    
    func updatePrompt() {
        if (disableAutoPrompt) { return }
        
        if let checkInFrequency = checkInTextField.text, type = typeTextField.text, name = nameTextField.text {
            if (type.isEmpty || checkInFrequency.isEmpty || name.isEmpty) { return }
            
            var query: String
            var when: String
            var interstitial: String = ""
            if (type == "Yes/No") {
                query = "Have you done"
            } else {
                query = "How many"
                interstitial = " have you done"
            }
            
            when = Frequency.thisNounify(Frequency(rawValue: checkInFrequency)!)
            
            promptTextField.text = query + " " + name + interstitial + " " + when + "?"
        }
    }
    
    func hideDetails() {
        for detail in details {
            detail.hidden = true
        }
    }
    
    func handleDetailDisclosure(detailLabel: UILabel) {
        let isHidden = detailLabel.hidden
        hideDetails()
        if (isHidden) { detailLabel.hidden = false } // otherwise leave it hidden
    }
    
    func allowSave() { // we check emptiness in reverse order since these should fill from the top down -- #efficiency
        if (promptTextField.text!.isEmpty ||
            checkInTextField.text!.isEmpty ||
            typeTextField.text!.isEmpty ||
            frequencyTextField.text!.isEmpty ||
            targetTextField.text!.isEmpty ||
            nameTextField.text!.isEmpty
            ) {
            saveButton.enabled = false
            
        } else {
            saveButton.enabled = true
        }
        
        
    }
}

