//
//  HistoryViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/23.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Properties
    var managedObjectContext: NSManagedObjectContext?
    private let estimatedRowHeight = CGFloat(60.0)
    
    var hasRecords: Bool {
        guard let fetchObjects = fetchedResultsController.fetchedObjects else {
            return false
        }
        return fetchObjects.count > 0
    }
    // MARK: -
    private lazy var fetchedResultsController: NSFetchedResultsController<Record> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Record.addedDate), ascending: false)]
        
        guard let managedObjectContext = self.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: #keyPath(Record.dateForSection), cacheName: nil)
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private func fetchRecords() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "历史记录"
        
        setupView()
        fetchRecords()
        updateView()
    }
    
    /// Configure messageLabel and tableView
    private func setupView() {
        setupMessageLabel()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.isHidden = true
        messageLabel.text = "无历史记录"
    }
    
    private func setupTableView() {
        tableView.isHidden = true
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func updateView() {
        messageLabel.isHidden = hasRecords
        tableView.isHidden = !hasRecords
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! HistoryTableViewCell
            configure(cell, at: indexPath!)
            case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else {
            return 0
        }
        return section.numberOfObjects
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else {
            return nil
        }
        let currentSection = sections[section]
        
        return currentSection.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.reuseIdentifier, for: indexPath) as? HistoryTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        // Fetch Note
        let record = fetchedResultsController.object(at: indexPath)
        
        // Delete this record in Note entity
        record.note?.timeCost -= record.timerLength
        
        // Delete Note
        guard let managedObjectContext = managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }
        managedObjectContext.delete(record)
    }
    
    func configure(_ cell: HistoryTableViewCell, at indexPath: IndexPath) {
        let record = fetchedResultsController.object(at: indexPath)
        
        cell.noteLabel.text = record.note?.contents
        cell.timerLengthLabel.text = String(format: "%.f", record.timerLength)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        let updateTime = dateFormatter.string(from: record.addedDate!)
        cell.upateTimeLabel.text = updateTime
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}

