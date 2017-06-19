//
//  ExpenseListVC.swift
//  Spare
//
//  Created by Matt Quiros on 03/03/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import Mold
import CoreData

fileprivate enum ViewID: String {
    case cell = "Cell"
    case header = "Header"
}

class ExpenseListVC: UIViewController {
    
    let customView = _ELVCView.instantiateFromNib()
    let totalCache = NSCache<NSNumber, NSDecimalNumber>()
    
    let fetchedResultsController: NSFetchedResultsController<Expense> = {
        let fetchRequest = FetchRequest<Expense>.make()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Expense.sectionDate), ascending: false),
            NSSortDescriptor(key: #keyPath(Expense.dateCreated), ascending: false)
        ]
        fetchRequest.fetchBatchSize = 30
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Global.coreDataStack.viewContext, sectionNameKeyPath: #keyPath(Expense.sectionDate), cacheName: "ExpenseListVCCache")
        return fetchedResultsController
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    func initialize() {
        self.tabBarItem.image = UIImage.templateNamed("tabIconExpenseList")
    }
    
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.title = "EXPENSES"
        
        self.customView.tableView.dataSource = self
        self.customView.tableView.delegate = self
        self.customView.tableView.register(_ELVCCell.nib(), forCellReuseIdentifier: ViewID.cell.rawValue)
        self.customView.tableView.register(_ELVCSectionHeader.nib(), forHeaderFooterViewReuseIdentifier: ViewID.header.rawValue)
        
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
            
            if let count = self.fetchedResultsController.fetchedObjects?.count {
                if count == 0 {
                    self.customView.activityIndicatorView.isHidden = true
                    self.customView.noExpensesLabel.isHidden = false
                    self.customView.tableView.isHidden = true
                } else {
                    self.customView.tableView.reloadData()
                    
                    self.customView.activityIndicatorView.isHidden = true
                    self.customView.noExpensesLabel.isHidden = true
                    self.customView.tableView.isHidden = false
                }
            }
        } catch {
            
        }
    }
    
    @discardableResult
    func computeAndCacheTotal(for section: Int) -> NSDecimalNumber {
        if let expenses = self.fetchedResultsController.sections?[section].objects as? [Expense],
            expenses.count > 0 {
            let total = expenses.total()
            self.totalCache.setObject(total, forKey: NSNumber(value: section))
            return total
        } else {
            self.totalCache.removeObject(forKey: NSNumber(value: section))
            return NSDecimalNumber(value: 0)
        }
    }

}

extension ExpenseListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController.sections
            else {
                return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = self.fetchedResultsController.sections?[section]
            else {
                return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewID.cell.rawValue, for: indexPath) as! _ELVCCell
        cell.expense = self.fetchedResultsController.object(at: indexPath)
        return cell
    }
    
}

extension ExpenseListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ViewID.header.rawValue) as! _ELVCSectionHeader
        headerView.dateString = self.fetchedResultsController.sections?[section].name
        if let computedTotal = self.totalCache.object(forKey: NSNumber(value: section)) {
            headerView.sectionTotal = computedTotal
        } else {
            headerView.sectionTotal = self.computeAndCacheTotal(for: section)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
}

extension ExpenseListVC: NSFetchedResultsControllerDelegate {

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch controller.fetchedObjects?.count ?? 0 {
        case 0:
            self.customView.activityIndicatorView.isHidden = true
            self.customView.noExpensesLabel.isHidden = false
            self.customView.tableView.isHidden = true
            
        default:
            self.customView.activityIndicatorView.isHidden = true
            self.customView.noExpensesLabel.isHidden = true
            
            self.customView.tableView.reloadData()
            self.customView.tableView.isHidden = false
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let oldSection = indexPath?.section {
            self.computeAndCacheTotal(for: oldSection)
        }
        
        if let newSection = newIndexPath?.section {
            self.computeAndCacheTotal(for: newSection)
        }
    }
    
}