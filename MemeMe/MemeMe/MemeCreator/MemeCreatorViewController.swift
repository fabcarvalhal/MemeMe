//
//  ViewController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 21/03/21.
//

import UIKit

class MemeCreatorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIFontPickerViewControllerDelegate {
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
        }
    }
    
    @IBOutlet weak var bottomTextField: UITextField! {
        didSet {
            bottomTextField.delegate = self
        }
    }
    
    @IBOutlet weak var shareButton: UIBarButtonItem! {
        didSet {
            shareButton.isEnabled = false
        }
    }
    
    
    // MARK: Useful variables and constants
    func getMemeTextAttributes(using fontName: String) -> [NSAttributedString.Key: Any] {
        return  [
            NSAttributedString.Key.strokeColor: fontName == defaultFontName ? UIColor.black : UIColor.white,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: fontName, size: 40) ?? UIFont.systemFont(ofSize: 40),
            NSAttributedString.Key.strokeWidth:  -5.0,
            NSAttributedString.Key.paragraphStyle: placeholderParagraphStyle
        ]
    }
    
    lazy var  placeholderParagraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }()
    
    private let defaultTopText = "TOP"
    private let defaultBottomText = "BOTTOM"
    private let defaultFontName = "HelveticaNeue-CondensedBlack"
    
    func getAttributedPlaceHolder(_ text: String, fontName: String) -> NSAttributedString{
        return NSAttributedString(string: text, attributes: getMemeTextAttributes(using: fontName))
    }
    
    // MARK: Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabelFonts(fontName: defaultFontName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK Cancel action
    @IBAction func cancelAction() {
        updateLabelFonts(fontName: defaultFontName)
        topTextField.text = nil
        bottomTextField.text = nil
        pickedImageView.image = nil
        shareButton.isEnabled = false
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
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Meme generation functions
    @IBAction func shareMeme(_ sender: AnyObject) {
        view.resignFirstResponder()
        let memedImage = generateMeme()
        let shareActivityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareActivityController.completionWithItemsHandler = { [weak self] activity, success, items, error in
            if success {
                _ = Meme(image: self?.pickedImageView.image ?? UIImage(), topText: self?.topTextField.text, bottomText: self?.bottomTextField.text, memedImage: memedImage)
            }
        }
        present(shareActivityController, animated: true)
    }
    
    func generateMeme() -> UIImage {
        
        toggleTopAndBottomBars(true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        toggleTopAndBottomBars(false)
        return memedImage
    }
    
    func toggleTopAndBottomBars(_ isHidden: Bool) {
        navigationController?.isNavigationBarHidden = isHidden
        navigationController?.isToolbarHidden = isHidden
    }
    
    
    // MARK: Function to show font picker controller
    @IBAction func showFontSelector(_ sender: AnyObject) {
        let fontPicker = UIFontPickerViewController()
        fontPicker.delegate = self
        present(fontPicker, animated: true, completion: nil)
    }
    
    
    // MARK: Font Picker Delegate Functions
    
    func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        updateLabelFonts(fontName: viewController.selectedFontDescriptor?.postscriptName ?? defaultFontName)
    }
    
    // MARK: Labels Configuration
    
    func updateLabelFonts(fontName: String) {
        configure(textField: bottomTextField, withPlaceholder: defaultBottomText, and: fontName)
        configure(textField: topTextField, withPlaceholder: defaultTopText, and: fontName)
    }
    
    func configure(textField: UITextField, withPlaceholder text: String, and fontName: String) {
        textField.defaultTextAttributes = getMemeTextAttributes(using: fontName)
        textField.attributedPlaceholder = NSAttributedString(string: text, attributes: getMemeTextAttributes(using: fontName))
    }
}


