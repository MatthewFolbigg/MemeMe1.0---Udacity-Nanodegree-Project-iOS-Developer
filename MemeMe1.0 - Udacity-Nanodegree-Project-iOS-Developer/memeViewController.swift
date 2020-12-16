//
//  ViewController.swift
//  MemeMe1.0 - Udacity-Nanodegree-Project-iOS-Developer
//
//  Created by Matthew Folbigg on 14/12/2020.
//

import UIKit

//MARK: Meme Creator View Controller
class memeViewController: UIViewController {
    
    //MARK:Outlets and Variables
    @IBOutlet var memeImageView: UIImageView!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    @IBOutlet var imageToolbar: UIToolbar!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet var textFontButton: UIBarButtonItem!
    @IBOutlet var textSizeButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var memeView: UIView!
    
    var savedMeme: Meme!
    
    var memeImage: UIImage!
    var isKeyboardShown: Bool!
    var keyboardCoversCurrentTextField: Bool!
    var allTextFields: [UITextField]!
    var textSize: CGFloat!
    
    //Text Style Settings
    var textModifier: CGFloat = 10 //FIXME: CHANGE THIS TO BEIGN SET BY SETTING PAGE
    var memeFont: String = "Impact"
    
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        allTextFields = [topTextField, bottomTextField]
        setDefaultUI()
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        isKeyboardShown = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:ToolBar Actions
    @IBAction func cameraButtonDidTapped(_ sender: Any) {
        getImageFrom(source: .camera)
    }
    
    @IBAction func photoLibaryButtonDidTapped(_ sender: Any) {
        getImageFrom(source: .photoLibrary)
    }
    
    //MARK: Reset Button Action
    @IBAction func resetButtonDidTapped() {
        returnAllTextFields()
        setDefaultUI()
        memeFont = "Impact"
        textModifier = 10
        setMemeTextFieldStyle(for: allTextFields)
    }
    
    
    //MARK: UI
    func setDefaultUI() {
        //Background Colour
        view.backgroundColor = .black
        //Text Field Defaults
        setupTextFields()
        //Image
        setupImageView()
        //Buttons & Bars
        setShareButton() //(Must be set after image to ensure correct state)
        setCameraButton()
        setupNavigationBar()
        setupToolBar()
        setTextFontButton()
        setTextSizeButton()
    }
    
    func setupTextFields() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        setMemeTextFieldStyle(for: allTextFields)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .systemTeal
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemTeal]
    }
    
    func setupImageView() {
        memeImageView.backgroundColor = .darkGray
        memeImageView.image = nil
        memeImageView.contentMode = .scaleAspectFit
    }
    
    func setupToolBar() {
        imageToolbar.barTintColor = .black
        imageToolbar.tintColor = .systemTeal
    }
    
    func setShareButton() {
        if memeImageView.image == nil {
            shareButton.isEnabled = false
        } else {
            shareButton.isEnabled = true
        }
    }
    
    func setCameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton.isEnabled = true
        } else {
            cameraButton.isEnabled = false
        }
    }
    
    func setTextFontButton() {
        let impactMenuItem = UIAction(title: "Impact") {_ in
            self.memeFont = "Impact"
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        let helveticaMenuItem = UIAction(title: "Helvetica") {_ in
            self.memeFont = "Helvetica Bold"
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        let futuraBoldMenuItem = UIAction(title: "Futura") {_ in
            self.memeFont = "Futura Bold"
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        
        let fontMenu = UIMenu(title: "Font", children: [impactMenuItem, helveticaMenuItem, futuraBoldMenuItem])
        textFontButton.menu = fontMenu
    }
    
    func setTextSizeButton() {
        let smallMenuItem = UIAction(title: "Small") {_ in
            self.textModifier = 14
            self.updateTextSize()
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        let mediumMenuItem = UIAction(title: "Medium") {_ in
            self.textModifier = 10
            self.updateTextSize()
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        let largeMenuItem = UIAction(title: "Large") {_ in
            self.textModifier = 6
            self.updateTextSize()
            self.setMemeTextFieldStyle(for: self.allTextFields)
    }
        
        let sizeMenu = UIMenu(title: "Text Size", children: [smallMenuItem, mediumMenuItem, largeMenuItem])
        textSizeButton.menu = sizeMenu
    }
}




//MARK: Meme Image Handling
extension memeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getImageFrom(source: UIImagePickerController.SourceType) {
        returnAllTextFields()
        let pickerController = UIImagePickerController()
        pickerController.sourceType = source
        pickerController.allowsEditing = true
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            memeImageView.image = image
            setMemeTextFieldStyle(for: allTextFields)
        }
        setShareButton()
        dismiss(animated: true, completion: nil)
    }
}




//MARK: Meme Text Handling
extension memeViewController: UITextFieldDelegate {
    
    //Text Field Sytle & Text style
    func setMemeTextFieldStyle(for textFields: [UITextField]) {
        
        updateTextSize()
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: memeFont, size: textSize)!,
            NSAttributedString.Key.strokeWidth:  -5
        ]

        for field in textFields {
            field.defaultTextAttributes = memeTextAttributes
            field.textAlignment = .center
            field.returnKeyType = .done
            field.autocapitalizationType = .allCharacters
            field.borderStyle = .none
            field.autocorrectionType = .no
        }
    }
    
    func returnAllTextFields() {
        //Used to prevent loosing current text if a text field is still selected when the share button or camera/photo library button is tapped.
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
    
    //Text Field Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        if textField.tag == 1 {
            keyboardCoversCurrentTextField = true
        } else {
            keyboardCoversCurrentTextField = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Prevent keyboard from hiding bottom text field
    @objc func keyboardWillShow(notification: NSNotification) {
        if isKeyboardShown == false && keyboardCoversCurrentTextField == true {
            if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                view.frame.origin.y -= keyboardRect.height
            }
        }
        isKeyboardShown = true
    }
    
    @objc func keyboardWillHide() {
        if isKeyboardShown == true && keyboardCoversCurrentTextField == true {
            view.frame.origin.y = 0
        }
        isKeyboardShown = false
    }
    
    //Changes text size to maintain relative size compared to the meme image when roataing device
    func updateTextSize() {
        textSize = memeImageView.frame.height/textModifier
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setMemeTextFieldStyle(for: allTextFields)
    }
}



//MARK: Meme Object Generation & Sharing
extension memeViewController {
    
    func generateMemedImage() -> UIImage {

        let renderer = UIGraphicsImageRenderer(size: memeView.frame.size)
        let memedImage = renderer.image { ctx in
            memeView.drawHierarchy(in: memeView.bounds, afterScreenUpdates: true)
        }
        return memedImage
    }
    
    func saveMeme() {
        savedMeme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, background: memeImageView.image!, memeImage: memeImage)
    }
    
    //MARK: Share Action
    @IBAction func shareButtonDidTapped() {
        returnAllTextFields()
        memeImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memeImage!], applicationActivities: nil)
        present(activityController, animated: true) {
            self.saveMeme()
        }
    }
}
