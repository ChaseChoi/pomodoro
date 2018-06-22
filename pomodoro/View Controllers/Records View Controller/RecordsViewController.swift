//
//  RecordsViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/22.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import Charts
import CoreData

class RecordsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var cancelBtn:  UIBarButtonItem!
    @IBOutlet weak var pieChartView: PieChartView!
    // MARK: Managed Object Context
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的统计"
    }

    // MARK: -
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
