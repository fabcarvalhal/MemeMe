//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 24/04/21.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet private weak var memedImageView: UIImageView!
    private let editMemeSegueIdentifier = "editMemeSegue"
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: meme)
    }
    
    private func configure(with meme: Meme) {
        self.memedImageView.image = meme.memedImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
           let destinationController = navigationController.topViewController as? MemeCreatorViewController,
           segue.identifier == editMemeSegueIdentifier {
            destinationController.creatorMode = .edit
            destinationController.memeForEdition = meme
            destinationController.editionDelegate = self
        }
    }
}

extension MemeDetailViewController: MemeCreatorEditionDelegate {
    func memeCreatorDidFinishEdit(_ editedMeme: Meme) {
        configure(with: editedMeme)
    }
}
