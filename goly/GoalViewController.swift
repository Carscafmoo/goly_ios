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
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var nameDetail: HideableLabel!
    @IBOutlet weak var targetDetail: HideableLabel!
    @IBOutlet weak var frequencyDetail: HideableLabel!
    @IBOutlet weak var typeDetail: HideableLabel!
    @IBOutlet weak var checkInDetail: HideableLabel!
    @IBOutlet weak var promptDetail: HideableLabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Picker views
    // Open question -- better to have one PV that responds differently depending on what FR is?
    // Or better to have several, distinct PVs?  I went with latter for easiness of if statements in 
    // delegate fxns
    let frequencyPickerView = UIPickerView()
    let typePickerView = UIPickerView()
    let checkInPickerView = UIPickerView()
    
    // Stuff populating picker view
    var frequencies = [String]()
    var types = [String]()
    
    // Collection of details for easy iteration
    var details = [HideableLabel]()
    
    // Whether the prompt text field has been manually updated yet
    var disableAutoPrompt: Bool = false
    
    // Keep track of which field is being edited so we can scroll to it as necessary
    var activeField: UITextField?
    
    var goal: Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        nameTextField.delegate = self
        promptTextField.delegate = self
        frequencyTextField.delegate = self
        typeTextField.delegate = self
        targetTextField.delegate = self
        targetTextField.keyboardType = .numberPad
        checkInTextField.delegate = self
        
        frequencyPickerView.delegate = self
        frequencies = ["Daily", "Weekly", "Monthly", "Quarterly", "Yearly"]
        frequencyTextField.inputView = frequencyPickerView
        
        typePickerView.delegate = self
        types = ["Yes/No", "Numeric"]
        typeTextField.inputView = typePickerView
        
        checkInPickerView.delegate = self
        // re-use frequencies
        checkInTextField.inputView = checkInPickerView
        
        // Hide all of the details
        details = [nameDetail, targetDetail, frequencyDetail, typeDetail, checkInDetail, promptDetail]
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
            activeSwitch.isOn = goal.active
            
            if (goal.checkIns.count > 0) {
                checkInTextField.isEnabled = false
                frequencyTextField.isEnabled = false
            }
        } else {
            activeLabel.isHidden = true
            activeSwitch.isHidden = true
        }
        
        allowSave() // disable the save button as necessary!
        
        // Watch for the keyboard to show, if it shows, deal with your scrolling
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if saveButton === sender as? UIBarButtonItem {
            let name = nameTextField.text ?? ""
            let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let frequency = Frequency(rawValue: frequencyTextField.text!)!
            let type = Type(rawValue: typeTextField.text!)!
            let target = Int(targetTextField.text!)!
            let cif = Frequency(rawValue: checkInTextField.text!)!
            let prompt = promptTextField.text ?? ""
            let active = activeSwitch.isOn
            if let goal = goal {
                goal.name = trimmedName
                goal.frequency = frequency
                goal.type = type
                goal.target = target
                goal.checkInFrequency = cif
                goal.prompt = prompt
                goal.active = active
                disableAutoPrompt = true
            } else { // it's a new goal
                goal = Goal(name: trimmedName, prompt: prompt, frequency: frequency, target: target, type: type, checkInFrequency: cif)
            }
        }
    }
    
    // MARK: text field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        if (textField == frequencyTextField) {
            if (textField.text == "") {
                textField.text = frequencies[frequencyPickerView.selectedRow(inComponent: 0)]
            } else {
                if let index = frequencies.index(of: textField.text!) {
                    frequencyPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        } else if (textField == typeTextField) {
            if (textField.text == "") {
                textField.text = types[typePickerView.selectedRow(inComponent: 0)]
            } else {
                if let index = types.index(of: textField.text!) {
                    typePickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        } else if (textField == checkInTextField) {
            let checkInFrequencies = filterCheckInFrequencies()
            if (textField.text == "") {
                textField.text = checkInFrequencies[checkInPickerView.selectedRow(inComponent: 0)]
            } else {
                if let index = checkInFrequencies.index(of: textField.text!) {
                    checkInPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // hide the keyboard
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
        if (textField == nameTextField) {
            navigationItem.title = textField.text
        } else if (textField == promptTextField) {
            disableAutoPrompt = true
        }
        
        updatePrompt() // textFieldDidEndEditing only runs for keyboard inputs and must be run in pickerViews separately
        allowSave() // Do this after updatePrompt so it takes into account the prompt value
    }
    
    // MARK: Picker View DS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == frequencyPickerView) {
            return frequencies.count
        } else if (pickerView == typePickerView) {
            return types.count
        } else if (pickerView == checkInPickerView) {
            return filterCheckInFrequencies().count
        } else {
            return 0
        }
    }
    
    // MARK: Picker view delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == frequencyPickerView) {
            return frequencies[row]
        } else if (pickerView == typePickerView) {
            return types[row]
        } else if (pickerView == checkInPickerView) {
            return filterCheckInFrequencies()[row]
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == frequencyPickerView) {
            frequencyTextField.text = frequencies[row]
            if (!checkInTextField.text!.isEmpty) {
                if let freq = Frequency(rawValue: frequencyTextField.text!), let cif = Frequency(rawValue:checkInTextField.text!) {
                    if (!Frequency.conforms(freq, checkInFrequency: cif)) {
                        checkInTextField.text = ""
                    }
                }
            }
        } else if (pickerView == typePickerView) {
            typeTextField.text = types[row]
        } else if (pickerView == checkInPickerView) {
            checkInTextField.text = filterCheckInFrequencies()[row]
        }
    }
    
    // MARK: Detail disclosures
    @IBAction func discloseNameDetail(_ sender: UIButton) {
        handleDetailDisclosure(nameDetail)
    }
    
    @IBAction func discloseFrequencyDetail(_ sender: UIButton) {
        handleDetailDisclosure(frequencyDetail)
    }
    
    @IBAction func discloseTypeDetail(_ sender: UIButton) {
        handleDetailDisclosure(typeDetail)
    }
    
    @IBAction func discloseTargetDetail(_ sender: UIButton) {
        handleDetailDisclosure(targetDetail)
    }
    
    @IBAction func discloseCheckInDetail(_ sender: UIButton) {
        handleDetailDisclosure(checkInDetail)
    }
    
    @IBAction func disclosePromptDetail(_ sender: UIButton) {
        handleDetailDisclosure(promptDetail)
    }
    
    // MARK: Helpers
    func filterCheckInFrequencies() -> [String] {
        if let curFreqText = frequencyTextField.text, let curFreq = Frequency(rawValue: curFreqText) {
            return frequencies.filter { (x) in Frequency.conforms(curFreq, checkInFrequency: Frequency(rawValue: x)!) }
        } else {
            return frequencies
        }
    }
    
    func updatePrompt() {
        if (disableAutoPrompt) { return }
        
        if let checkInFrequency = checkInTextField.text, let type = typeTextField.text, let name = nameTextField.text?.lowercased() {
            let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (type.isEmpty || checkInFrequency.isEmpty || trimmedName.isEmpty) { return }
            
            var query: String
            var when: String
            var interstitial: String = ""
            if (type == "Yes/No") {
                query = "Did you"
            } else {
                query = "How many"
                interstitial = " did you do"
            }
            
            when = Frequency.thisNounify(Frequency(rawValue: checkInFrequency)!)
            
            promptTextField.text = query + " " + trimmedName + interstitial + " " + when + "?"
        }
    }
    
    func hideDetails() {
        for detail in details {
            detail.hide()
        }
    }
    
    func handleDetailDisclosure(_ detailLabel: HideableLabel) {
        let isHidden = detailLabel.isHidden
        hideDetails()
        if (isHidden) {
            detailLabel.show()
        } // otherwise leave it hidden
    }
    
    func allowSave() { // we check emptiness in reverse order since these should fill from the top down -- #efficiency
        let trimmedPrompt = promptTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let trimmedName = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (trimmedPrompt.isEmpty ||
            checkInTextField.text!.isEmpty ||
            typeTextField.text!.isEmpty ||
            frequencyTextField.text!.isEmpty ||
            targetTextField.text!.isEmpty ||
            trimmedName.isEmpty
            ) {
            saveButton.isEnabled = false
            
        } else {
            saveButton.isEnabled = true
        }
        
        
    }
    
    //MARK: Keyboard scrolling
    func keyboardDidShow(_ notification: Notification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
}

