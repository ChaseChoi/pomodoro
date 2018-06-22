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
    var notes: [Note]?
    var notesDataEntries = [PieChartDataEntry]()
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "我的统计"
        pieChartView.chartDescription?.text = ""
        pieChartView.noDataText = "暂无数据"
        getTodayNotes()
        populateDataEntries()
    }

    func getTodayNotes() {
        let request = NSFetchRequest<Note>()
        request.entity = Note.entity()
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let date = Date()
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        let fromPredicate = NSPredicate(format: "%@ >= %@", date as NSDate, dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "%@ < %@", date as NSDate, dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            notes = try managedObjectContext?.fetch(request)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    func populateDataEntries() {
        if let notes = notes {
            for note in notes {
                if note.hoursCost != 0 {
                    let dataEntry = PieChartDataEntry(value: note.hoursCost)
                    dataEntry.label = note.contents
                    notesDataEntries.append(dataEntry)
                }
            }
        }
        if notesDataEntries.count > 0 {
            updateChartData()
        }
    }
    
    func updateChartData() {
        let chartDataSet = PieChartDataSet(values: notesDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        // Formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        chartDataSet.valueFormatter = formatter as? IValueFormatter
        
        chartDataSet.colors = ChartColorTemplates.material()
        // Update
        pieChartView.data = chartData
        pieChartView.animate(xAxisDuration: 1, yAxisDuration: 1, easingOption: .easeOutQuad)
    }

    // MARK: -
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
}
