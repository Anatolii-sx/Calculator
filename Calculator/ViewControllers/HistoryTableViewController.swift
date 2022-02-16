//
//  HistoryTableViewController.swift
//  Calculator
//
//  Created by Анатолий Миронов on 15.02.2022.
//

import UIKit

// MARK: - HistoryTableViewProtocol (Connection Presenter -> View)
protocol HistoryTableViewProtocol: AnyObject {
    func reloadData()
    func deleteRow(indexPath: IndexPath)
}

class HistoryTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var presenter: HistoryPresenterProtocol!

    // MARK: - Methods Of ViewController's Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = HistoryPresenter(view: self)
        presenter.fetchData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getNumberOfRows()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let history = presenter.history[indexPath.row]
        cell.textLabel?.text = history.result
        cell.detailTextLabel?.text = history.result
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteButtonTapped(indexPath: indexPath)
        }
    }
    
    @IBAction func clearButton(_ sender: UIBarButtonItem) {
        presenter.clearButtonTapped()
    }
}

// MARK: - Realization HistoryTableViewProtocol Methods (Connection Presenter -> View)
extension HistoryTableViewController: HistoryTableViewProtocol {    
    func reloadData() {
        tableView.reloadData()
    }
    
    func deleteRow(indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
