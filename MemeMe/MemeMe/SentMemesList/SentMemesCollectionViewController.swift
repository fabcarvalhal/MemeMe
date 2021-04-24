//
//  SentMemesCollectionController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class SentMemesCollectionController: UICollectionViewController {
    
    private let memeDetailSegueIdentifier = "showMemeDetail"
    private let interItemSpacing: CGFloat = 2
    private let lineSpacing: CGFloat = 4
    private let itemsPerLine: CGFloat = 3
    
    private lazy var itemSize: CGSize = {
        let itemWidth = collectionView.bounds.width / itemsPerLine - interItemSpacing
        let itemHeight = itemWidth - lineSpacing
        return CGSize(width: itemWidth,
                      height: itemHeight)
    }()
    
    private var dataSource = [Meme]()
    private let itemIdentifier = "sentMemesItemIdentifier"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCollectionData()
    }
    
    private func loadCollectionData() {
        dataSource = MemeStorage.instance.getList()
        collectionView.reloadData()
    }
    
    // MARK: - DataSource Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemIdentifier, for: indexPath) as? MemeListCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: dataSource[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

// MARK: - UICollectionViewDelegateFlowLayout
extension SentMemesCollectionController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
