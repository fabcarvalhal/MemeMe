//
//  ViewController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 21/03/21.
//

import UIKit

class MemeCreatorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem! {
        didSet {
            cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    @IBOutlet weak var topTextField: UITextField! {
        didSet {
            topTextField.delegate = self
            topTextField.attributedPlaceholder = NSAttributedString(string: defaultTopText, attributes: memeTextAttributes)
            topTextField.defaultTextAttributes = memeTextAttributes
        }
    }
    
    @IBOutlet weak var bottomTextField: UITextField! {
        didSet {
            bottomTextField.delegate = self
            bottomTextField.attributedPlaceholder = NSAttributedString(string: defaultBottomText, attributes: memeTextAttributes)
            bottomTextField.defaultTextAttributes = memeTextAttributes
        }
    }
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    
    
    // MARK: Useful variables and constants
    lazy var memeTextAttributes: [NSAttributedString.Key: Any] = {
        return  [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) ?? UIFont.systemFont(ofSize: 40),
            NSAttributedString.Key.strokeWidth:  -5.0,
            NSAttributedString.Key.paragraphStyle: placeholderParagraphStyle
        ]
    }()
    
    lazy var  placeholderParagraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()
    
    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"

    
    // MARK: Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: Pick image
    @IBAction func pickImage(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sender.tag == 0 ? .camera : .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pickedImageView.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Keyboard functions
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        return keyboardFrame?.cgRectValue.height ?? 0
    }
    
    func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Meme generation functions
    @IBAction func shareMeme(_ sender: AnyObject) {
        view.resignFirstResponder()
        let memedImage = generateMeme()
        let shareActivityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareActivityController.completionWithItemsHandler = { [weak self] activity, success, items, error in
            _ = Meme(image: self?.pickedImageView.image ?? UIImage(), topText: self?.topTextField.text, bottomText: self?.bottomTextField.text, memedImage: memedImage)
            // no place to save this right now
        }
        present(shareActivityController, animated: true)
    }
    
    func generateMeme() -> UIImage {
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.isToolbarHidden = true

        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        return memedImage
    }
    
}


