//
//  AddNoteTableViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/21.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import CoreData

class AddNoteTableViewController: UITableViewController {
    // MARK: - Properties
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "新建事项"
        textField.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - IBAction
    @IBAction func done() {
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        // Create Note
        let note = Note(context: managedObjectContext)
        
        // Configure Note
        note.contents = textField.text!
        note.createdAt = Date()
        note.timeCost = 0.0
        
        // Pop View Controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

}

// MARK: - UITextFieldDelegate
extension AddNoteTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneButton.isEnabled = newText.length > 0
        return true
    }
}
