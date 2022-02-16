//
//  StorageManager.swift
//  Calculator
//
//  Created by Анатолий Миронов on 15.02.2022.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "History")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    func save(_ result: String, completion: ((History) -> Void)?) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "History", in: viewContext) else { return }
        guard let history = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? History else { return }
        history.result = result
        if let completion = completion {
            completion(history)
        }
        saveContext()
    }
    
    func fetchData(completion: (Result<[History], Error>) -> Void) {
        let fetchRequest = History.fetchRequest()

        do {
            let history = try viewContext.fetch(fetchRequest)
            completion(.success(history))
        } catch let error {
            completion(.failure(error))
        }
    }

    func delete(_ history: History) {
        viewContext.delete(history)
        saveContext()
    }
    
    func deleteAllHistory() {
        fetchData { result in
            switch result {
            case .success(let history):
                history.forEach { viewContext.delete($0) }
                saveContext()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
