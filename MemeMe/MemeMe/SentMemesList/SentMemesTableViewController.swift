//
//  SentMemesTableListController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class SentMemesTableController: UITableViewController {
    
    private let memeDetailSegueIdentifier = "showMemeDetail"
    private let cellIdentifier = "tableCellIdentifier"
    private var dataSource = [Meme]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        self.navigationItem.title = "Sent Memes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTableData()
    }
    
    private func loadTableData() {
        dataSource = MemeStorage.instance.getList()
        tableView.reloadData()
    }
    
    
    // MARK: - DataSource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MemeListTableCell else {
            return UITableViewCell()
        }
        cell.configure(with: dataSource[indexPath.row])
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    // MARK: - Delegate Methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MemeStorage.instance.remove(at: indexPath.row)
            loadTableData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: memeDetailSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MemeDetailViewController,
           let sender = sender as? IndexPath,
           segue.identifier == memeDetailSegueIdentifier {
            destination.meme = dataSource[sender.row]
        }
    }
}
