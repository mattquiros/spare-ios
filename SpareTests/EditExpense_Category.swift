//
//  EditExpense_Category.swift
//  SpareTests
//
//  Created by Matt Quiros on 14/09/2017.
//  Copyright © 2017 Matt Quiros. All rights reserved.
//

import XCTest
import CoreData
@testable import Spare

class EditExpense_Category: CoreDataTestCase {
    
    override func setUp() {
        super.setUp()
        makeExpenses(from: [
            RawExpense(amount: "250.00", dateSpent: Date(), categorySelection: .name("Food"), tagSelection: .none),
            RawExpense(amount: "164.11", dateSpent: Date(), categorySelection: .name("Transportation"), tagSelection: .none),
            RawExpense(amount: "7.00", dateSpent: Date(), categorySelection: .name("Transportation"), tagSelection: .none),
            RawExpense(amount: "149.00", dateSpent: Date(), categorySelection: .name("Food"), tagSelection: .none),
            RawExpense(amount: "16", dateSpent: Date(), categorySelection: .name("Transportation"), tagSelection: .none)
            ])
    }
    
    func testEnteredName_sameAsCurrentCategoryName_shouldNotChange() {
        // Get the first expense.
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Expense.category.name), "Food")
        guard let expense = (try? coreDataStack.viewContext.fetch(fetchRequest))?.first
            else {
                XCTFail()
                return
        }
        
        let rawExpense = RawExpense(amount: "999", dateSpent: expense.dateSpent!, categorySelection: .name("Food"), tagSelection: .none)
        let validateOp = ValidateExpenseOperation(rawExpense: rawExpense, context: coreDataStack.newBackgroundContext(), completionBlock: nil)
        validateOp.start()
        
        guard case .success(let validExpense) = validateOp.result
            else {
            fatalError()
        }
        
        let editOp = EditExpenseOperation(context: coreDataStack.viewContext,
                                          expenseId: expense.objectID,
                                          validExpense: validExpense,
                                          completionBlock: nil)
        let currentCategory = editOp.fetchExpense()?.category
        let shouldChange = editOp.shouldChangeCategory(currentCategory, with: validExpense.categorySelection)
        XCTAssertFalse(shouldChange)
        
        // Actually perform operation
        editOp.start()
        guard case .success(let expenseId) = editOp.result,
            let editedExpense = coreDataStack.viewContext.object(with: expenseId) as? Expense
            else {
                fatalError()
        }
        XCTAssertEqual(editedExpense.category?.name, "Food")
    }
    
    func testEnteredName_usingExistingCategory_shouldUpdateClassifierAndClassifierGroups() {
        let expense1: Expense = {
            let request: NSFetchRequest<Expense> = Expense.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(Expense.category.name), "Food")
            return (try! coreDataStack.viewContext.fetch(request)).first!
        }()
        let expense2: Expense = {
            let request: NSFetchRequest<Expense> = Expense.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(Expense.category.name), "Transportation")
            return (try! coreDataStack.viewContext.fetch(request)).first!
        }()
        
        let newCategoryEnteredName = expense2.category!.name!
        let validExpense = makeValidEnteredExpense(from: RawExpense(amount: "333.45",
                                                                           dateSpent: expense2.dateSpent!,
                                                                           categorySelection: .name(newCategoryEnteredName),
                                                                           tagSelection: .none))
        let editOp = EditExpenseOperation(context: coreDataStack.viewContext,
                                          expenseId: expense1.objectID,
                                          validExpense: validExpense,
                                          completionBlock: nil)
        var expenseToEdit = editOp.fetchExpense()!
        
        let shouldChange = editOp.shouldChangeCategory(expenseToEdit.category, with: validExpense.categorySelection)
        XCTAssertTrue(shouldChange)
        
        let replacementCategory = editOp.fetchOrMakeReplacementCategory(fromSelection: validExpense.categorySelection)
        XCTAssertEqual(replacementCategory.name, newCategoryEnteredName)
        XCTAssertEqual(replacementCategory.name, expense2.category?.name)
        XCTAssertEqual(replacementCategory.objectID, expense2.category?.objectID)
        
        let currentDayCategoryGroup = expenseToEdit.dayCategoryGroup
        let currentWeekCategoryGroup = expenseToEdit.weekCategoryGroup
        let currentMonthCategoryGroup = expenseToEdit.monthCategoryGroup
        
        let newDayCategoryGroup = editOp.fetchReplacementClassifierGroup(periodization: .day, classifier: replacementCategory, dateSpent: validExpense.dateSpent)
        XCTAssertNotNil(newDayCategoryGroup)
        XCTAssertEqual(expense2.dayCategoryGroup, newDayCategoryGroup)
        XCTAssertNotEqual(currentDayCategoryGroup, newDayCategoryGroup)
        
        let newWeekCategoryGroup = editOp.fetchReplacementClassifierGroup(periodization: .week, classifier: replacementCategory, dateSpent: validExpense.dateSpent)
        XCTAssertNotNil(newWeekCategoryGroup)
        XCTAssertEqual(expense2.weekCategoryGroup, newWeekCategoryGroup)
        XCTAssertNotEqual(currentWeekCategoryGroup, newWeekCategoryGroup)
        
        let newMonthCategoryGroup = editOp.fetchReplacementClassifierGroup(periodization: .month, classifier: replacementCategory, dateSpent: validExpense.dateSpent)
        XCTAssertNotNil(newMonthCategoryGroup)
        XCTAssertEqual(expense2.monthCategoryGroup, newMonthCategoryGroup)
        XCTAssertNotEqual(currentMonthCategoryGroup, newMonthCategoryGroup)
        
        // Perform operation
        
        editOp.start()
        if case .success(let objectId) = editOp.result {
            expenseToEdit = coreDataStack.viewContext.object(with: objectId) as! Expense
            XCTAssertEqual(expenseToEdit.dayCategoryGroup, newDayCategoryGroup)
            XCTAssertEqual(expenseToEdit.weekCategoryGroup, newWeekCategoryGroup)
            XCTAssertEqual(expenseToEdit.monthCategoryGroup, newMonthCategoryGroup)
        } else {
            XCTFail()
        }
    }
    
}
