//
//  ViewController.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 21/03/21.
//

import UIKit

protocol MemeCreatorEditionDelegate: class {
    func memeCreatorDidFinishEdit(_ editedMeme: Meme)
}

class MemeCreatorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIFontPickerViewControllerDelegate {
    
    enum MemeCreatorMode {
        case create
        case edit
    }
    
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
    private var customFont: String?
    
    var creatorMode = MemeCreatorMode.create
    var memeForEdition: Meme?
    weak var editionDelegate: MemeCreatorEditionDelegate?
    
    func getAttributedPlaceHolder(_ text: String, fontName: String) -> NSAttributedString{
        return NSAttributedString(string: text, attributes: getMemeTextAttributes(using: fontName))
    }
    
    // MARK: Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    func configureView() {
        switch creatorMode {
        case .create:
            updateLabelFonts(fontName: defaultFontName)
        case .edit:
            guard let meme = memeForEdition else { return }
            displayMemeForEdition(meme)
        }
    }
    
    func displayMemeForEdition(_ meme: Meme) {
        topTextField.text = meme.topText
        bottomTextField.text = meme.bottomText
        pickedImageView.image = meme.image
        updateLabelFonts(fontName: meme.fontName)
        shareButton.isEnabled = true
    }
    
    // MARK Cancel action
    @IBAction func cancelAction() {
        updateLabelFonts(fontName: defaultFontName)
        topTextField.text = nil
        bottomTextField.text = nil
        pickedImageView.image = nil
        shareButton.isEnabled = false
        dismiss(animated: true)
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
            guard let self = self else { return }
            if success {
                let font = self.customFont ?? self.defaultFontName
                let newMeme = Meme(image: self.pickedImageView.image ?? UIImage(),
                                   topText: self.topTextField.text ?? self.defaultTopText,
                                   bottomText: self.bottomTextField.text ?? self.defaultBottomText,
                                   memedImage: memedImage,
                                   fontName: font)
                switch self.creatorMode {
                case .create:
                    MemeStorage.instance.save(newMeme)
                case .edit:
                    guard let oldMeme = self.memeForEdition else { return }
                    MemeStorage.instance.replace(oldMeme, with: newMeme)
                }
                self.editionDelegate?.memeCreatorDidFinishEdit(newMeme)
                self.dismiss(animated: true)
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
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        let selectedFontName = viewController.selectedFontDescriptor?.postscriptName
        customFont = selectedFontName
        updateLabelFonts(fontName: selectedFontName ?? defaultFontName)
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


