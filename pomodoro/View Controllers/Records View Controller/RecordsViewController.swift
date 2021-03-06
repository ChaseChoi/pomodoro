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
    // MARK: - Segue
    private enum Segue: String {
        case showHistory
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var historyBtn: UIBarButtonItem!
    @IBOutlet weak var todayTotalLabel: UILabel!
    
    // MARK: - Properties
    var notes: [Note]?
    var notesDataEntries = [PieChartDataEntry]()
    // MARK: Managed Object Context
    var managedObjectContext: NSManagedObjectContext?
    
    var hasNotes: Bool {
        return !notesDataEntries.isEmpty
    }
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notesDataEntries.removeAll()
        getTodayNotes()
        populateDataEntries()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "今日统计"
        todayTotalLabel.text = "0.0"

        setupPieChart()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case Segue.showHistory.rawValue:
            guard let historyViewController = segue.destination as? HistoryViewController else {
                return
            }
            historyViewController.managedObjectContext = managedObjectContext
        default:
            break
        }
    }
    
    // MARK: -
    func setupPieChart() {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        let dateInfo = formatter.string(from: Date())
        
        pieChartView.chartDescription?.text = ""
        pieChartView.noDataText = "暂无数据"
        pieChartView.noDataFont = UIFont.systemFont(ofSize: 17)
        pieChartView.noDataTextColor = UIColor(red: 152/255, green: 166/255, blue: 195/255, alpha: 1)
        pieChartView.legend.enabled = false
        pieChartView.centerText = dateInfo
        
    }
    
    // MARK: - Setup Notes Data
    func getTodayNotes() {
        let request = NSFetchRequest<Note>()
        request.entity = Note.entity()
        
        let today = Date()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateFrom = calendar.startOfDay(for: today)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        // Combining Predicates
        let fromPredicate = NSPredicate(format: "%K >= %@", #keyPath(Note.createdAt), dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "%K < %@", #keyPath(Note.createdAt), dateTo! as NSDate)
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
                $0 + $1.timeCost
            }
            todayTotalLabel.text = String(format: "%.1f", Double(sum/60))
            for note in notes {
                if note.timeCost != 0 {
                    let dataEntry = PieChartDataEntry(value: note.timeCost/sum, label: note.contents)
                    notesDataEntries.append(dataEntry)
                }
            }
        }

        if hasNotes {
            updateChartData()
        } else {
            pieChartView.data = nil
        }
    }
    
    func updateChartData() {
        let chartDataSet = PieChartDataSet(values: notesDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.sliceSpace = 2
        
        // Formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        // Use Color Template
        chartDataSet.colors = ChartColorTemplates.material()
        
        // Update
        pieChartView.data = chartData
        pieChartView.animate(xAxisDuration: 1, yAxisDuration: 1, easingOption: .easeOutQuad)
    }

    // MARK: - IBActions
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}
