//
//  ViewController.swift
//  Calculator
//
//  Created by Lorenzo Norcini on 31/07/2017.
//  Copyright © 2017 Lorenzo Norcini. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var calculator: CalculatorModel = CalculatorModel()

    @IBOutlet weak var calcDisplay: UILabelWithPadding!
    @IBOutlet weak var resultDisplay: UILabelWithPadding!
    @IBOutlet weak var symbolSelector: UIPickerView!
    
    private var selectedSymbol: String?

    @IBOutlet weak var toggleSymbolSelector: UIButton!
    
    @IBAction func createVar(_ sender: UIButton) {
        showVarCreator()
    }
    
    @IBAction func assignVar(_ sender: UIButton) {
        showVarCreator(value: calculator.result)
    }
    
    @IBAction func clearExpression(_ sender: UIButton) {
        calculator.clearExpression()
        update()
    }
    
    @IBAction func deleteLastSymbol(_ sender: UIButton) {
        calculator.deleteSymbol()
        update()
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let currentSymbol = sender.currentTitle!
        addToExpression(symbol: currentSymbol)
    }
    
    @IBAction func InsertSymbol(_ sender: UIButton) {
        if symbolSelector.isHidden{
            symbolSelector.isHidden = false
            sender.setTitle("OK", for: [])
        } else {
            symbolSelector.isHidden = true
            sender.setTitle("INSERT", for: [])
            addToExpression(symbol: selectedSymbol!)
        }
    }
    
    func addToExpression(symbol: String){
        calculator.addToExpression(symbol: symbol)
        update()
    }
    
    func update() {
        calcDisplay.text = calculator.expression
        resultDisplay.text = calculator.result
        if calculator.validState {
            calcDisplay.layer.borderColor = UIColor.green.cgColor
        } else {
            calcDisplay.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func showVarCreator(value: String? = nil){
        let alertController = UIAlertController(title: "Add Variable",
                                                message: "Type name and value for the variable",
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let name = alertController.textFields?[0].text,
                let value = alertController.textFields?[1].text{
                self.calculator.addConstant(name: name, value: Double(value) ?? 0)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Variable Name"
        }
        
        alertController.addTextField { (textField) in
            if value != nil{
                textField.placeholder = "Value"
                textField.text = value
            }else{
                textField.placeholder = "Value"
            }
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showExprEditor() {
        let alertController = UIAlertController(title: "Expression",
                                                message: "Modify the expression",
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            let val = alertController.textFields?[0].text
            self.calculator.expression = val!
            self.update()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.text = self.calculator.expression
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.showExprEditor))
        calcDisplay.isUserInteractionEnabled = true
        calcDisplay.addGestureRecognizer(tap)
        
        symbolSelector.delegate = self
        symbolSelector.dataSource = self
        symbolSelector.isHidden = true
        
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return calculator.getOperationsList().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return calculator.getOperationsList()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSymbol = calculator.getOperationsList()[row]
    }
    
}

