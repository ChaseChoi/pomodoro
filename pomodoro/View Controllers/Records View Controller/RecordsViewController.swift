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
        
        setupPieChart()
        getTodayNotes()
        populateDataEntries()
    }

    // MARK: -
    func setupPieChart() {
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone.local
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyy")
        let dateInfo = formatter.string(from: Date())
        
        pieChartView.chartDescription?.text = ""
        pieChartView.noDataText = "暂无数据"
        pieChartView.centerText = dateInfo
    }
    
    // MARK: - Setup Data
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
            let sum = notes.reduce(0) {
                $0 + $1.hoursCost
            }
            for note in notes {
                if note.hoursCost != 0 {
                    let dataEntry = PieChartDataEntry(value: note.hoursCost/sum, label: note.contents)
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
        
        chartDataSet.sliceSpace = 2
        
        // Formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        // Use Color Template
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
