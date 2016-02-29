//
//  PopoverViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 11.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let classes = ["1BIA", "1BIB", "2BIA", "2BIB", "3BIT", "Osobný rozvrh"]
    private let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet var classPickerOutlet: UIPickerView!
    
    @IBAction func saveClass(sender: UIBarButtonItem) {
        let chosenClass: String = pickerView(classPickerOutlet, titleForRow: classPickerOutlet.selectedRowInComponent(0), forComponent: 0)!
        
        defaults.setValue(chosenClass, forKeyPath: "class")
        defaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("loadAddressURLID", object: self, userInfo: ["class":chosenClass])
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classPickerOutlet.delegate = self
        classPickerOutlet.dataSource = self
        var index = 0
        if let selectedClass = defaults.stringForKey("class") {
            for (tmpIndex, myClass) in classes.enumerate() {
                if myClass == selectedClass {
                    index = tmpIndex; break
                }
            }
            classPickerOutlet.selectRow(index, inComponent: 0, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Class.allValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return classes[row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
