//
//  File.swift
//
//
//  Created by Finn Behrens on 25.03.22.
//

import CoreData
import Foundation
import OSLog

public protocol MatrixStoreManager {
    var viewContext: NSManagedObjectContext { get }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public class MatrixStore: MatrixStoreManager {
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: Logging

    let logger = Logger(subsystem: "dev.matrixcore", category: "matrixstore")

    // MARK: Core Data

    static let shared = MatrixStore()

    static let preview = MatrixStore(inMemory: true)

    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory

        notificationToken = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: nil
        ) { _ in
            self.logger.debug("Received a persistent store remote change notification.")
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }

    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?

    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        guard let url = Bundle.module.url(forResource: "MatrixCore", withExtension: "mom")
        else { fatalError("Could not get URL for model: MarixCore") }

        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }

        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "MatrixCore", managedObjectModel: model)

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // This sample refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()

    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }

    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            logger.debug("\(error.localizedDescription)")
        }
    }

    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        logger.debug("Start fetching persistent history changes from the store...")

        try await taskContext.perform {
            // Execute the persistent history change since the last transaction.
            /// - Tag: fetchHistory
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty
            {
                self.mergePersistentHistoryChanges(from: history)
                return
            }

            self.logger.debug("No persistent history transactions found.")
            throw MatrixCoreError.persistentHistoryChangeError
        }

        logger.debug("Finished merging history changes.")
    }

    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        logger.debug("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
}

/*
 open class MatrixStoreContainer: NSPersistentContainer {

     override open class func defaultDirectoryURL() -> URL {

         return super.defaultDirectoryURL()
             .appendingPathComponent("CoreDataModel")
             .appendingPathComponent("Local")
     }
 }

 open class MatrixStoreCloudKitContainer: NSPersistentCloudKitContainer {

     override open class func defaultDirectoryURL() -> URL {

         return super.defaultDirectoryURL()
             .appendingPathComponent("CoreDataModel")
             .appendingPathComponent("Cloud")
     }
 }

 */
