//
//  HistoryPresenter.swift
//  Calculator
//
//  Created by Анатолий Миронов on 15.02.2022.
//

import Foundation

// MARK: - HistoryPresenterProtocol (Connection View -> Presenter)
protocol HistoryPresenterProtocol {
    var history: [History] { get }
    init(view: HistoryTableViewProtocol)
    func fetchData()
    func getNumberOfRows() -> Int
    func clearButtonTapped()
    func deleteButtonTapped(indexPath: IndexPath)
}

class HistoryPresenter: HistoryPresenterProtocol {
    // MARK: - Public Properties
    var history: [History] = []
    
    // MARK: - Private Properties
    private unowned let view: HistoryTableViewProtocol
    
    // MARK: - Realization HistoryPresenterProtocol Init (Connection View -> Presenter)
    required init(view: HistoryTableViewProtocol) {
        self.view = view
    }
    
    // MARK: - Realization HistoryPresenterProtocol Methods (Connection View -> Presenter)
    func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let history):
                self.history = history
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNumberOfRows() -> Int {
        history.count
    }
    
    func clearButtonTapped() {
        history.removeAll()
        StorageManager.shared.deleteAllHistory()
        view.reloadData()
    }
    
    func deleteButtonTapped(indexPath: IndexPath) {
        let history = history[indexPath.row]
        self.history.remove(at: indexPath.row)
        view.deleteRow(indexPath: indexPath)
        StorageManager.shared.delete(history)
    }
}
