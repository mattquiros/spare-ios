//
//  TagPickerViewController.swift
//  Spare
//
//  Created by Matt Quiros on 05/07/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import UIKit
import CoreData
import Mold

private enum ViewID: String {
    case itemCell = "itemCell"
}

private enum Section: Int {
    case recents, allTags, newTag
}

class TagPickerViewController: UIViewController {
    
    class func present(from presenter: ExpenseFormViewController) {
        let picker = TagPickerViewController()
        picker.setCustomTransitioningDelegate(SlideUpPicker.sharedTransitioningDelegate)
        presenter.present(picker, animated: true, completion: nil)
    }
    
    let customView = TagPickerView.instantiateFromNib()
    
    var selectedTags = Set<NSManagedObjectID>()
    
    private let internalNavigationController = UINavigationController(nibName: nil, bundle: nil)
    
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.internalNavigationController.pushViewController(TagListViewController(), animated: false)
        self.embedChildViewController(self.internalNavigationController, toView: self.customView.contentView, fillSuperview: true)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnDimView))
        self.customView.dimView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTapOnDimView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -
fileprivate class TagListViewController: UITableViewController {
    
    let tagFetcher: NSFetchedResultsController<Tag> = {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tag.name), ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Global.coreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(PickerItemCell.nib(), forCellReuseIdentifier: ViewID.itemCell.rawValue)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        do {
            try self.tagFetcher.performFetch()
            self.tableView.reloadData()
        } catch {}
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allTags:
            return self.tagFetcher.fetchedObjects?.count ?? 0
        case .newTag:
            return 1
        case .recents:
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewID.itemCell.rawValue, for: indexPath) as! PickerItemCell
        
        switch Section(rawValue: indexPath.section)! {
        case .allTags:
            cell.nameLabel.text = self.tagFetcher.object(at: IndexPath(item: indexPath.item, section: 0)).name
        case .newTag:
            cell.nameLabel.text = "Add a new tag"
        case .recents:
            break
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section)! {
        case .newTag:
            self.navigationController?.pushViewController(NewClassifierViewController(classifierType: .tag), animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .allTags:
            return "All tags"
        case .newTag:
            return nil
        case .recents:
            return "Recent"
        }
    }
    
}
