//
//  NoteViewController.swift
//  pomodoro
//
//  Created by Chase Choi on 2018/6/21.
//  Copyright © 2018 Chase Choi. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    // MARK: - Segue
    private enum Segue: String {
        case AddNote
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let estimatedRowHeight = CGFloat(44.0)
    
    private var hasNotes: Bool {
        guard let fetchObjects = fetchedResultsController.fetchedObjects else {
            return false
        }
        return fetchObjects.count > 0
    }
    
    // MARK: -
    private var coreDataManager = CoreDataManager(modelName: "Notes")
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "待办事项"
        
        // Setup View
        setupView()
        fetchNotes()
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
        case Segue.AddNote.rawValue:
            guard let destination = segue.destination as? UINavigationController else {
                return
            }
            guard let addViewController = destination.topViewController as? AddNoteTableViewController else {
                return
            }
            addViewController.managedObjectContext = self.coreDataManager.managedObjectContext
        default:
            break;
        }

    }
    
    // MARK: -
    private lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.createdAt), ascending: false)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // MARK: - View Methods
    
    /// Configure messageLabel and tableView
    private func setupView() {
        setupMessageLabel()
        setupTableView()
    }
    
    private func setupMessageLabel() {
        messageLabel.isHidden = true
        messageLabel.text = "无待办事项"
    }
    
    private func setupTableView() {
        tableView.isHidden = true
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /// Display messageLabel or tableView as per hasNotes
    private func updateView() {
        tableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }
    // MARK: - Helper Methods
    
    /// perform fetch to get Notes data
    private func fetchNotes() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
}

extension NoteViewController: NSFetchedResultsControllerDelegate {
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
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
}

extension NoteViewController: UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        // Configure Cell
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: NoteTableViewCell, at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        
        cell.contentsLabel.text = note.contents
        cell.costTimeLabel.text = String(format: "%.1f", note.hoursCost)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)
        
        // Delete Note
        coreDataManager.managedObjectContext.delete(note)
    }
}

extension NoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
}




