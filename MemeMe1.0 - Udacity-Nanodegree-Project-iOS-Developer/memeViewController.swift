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
    @IBOutlet var shareButton: UIBarButtonItem!
    
    var memeImage: UIImage!
    var isKeyboardShown: Bool!
    var keyboardCoversCurrentTextField: Bool!
        
    //MARK:Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    func setupTextFields() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        setMemeTextFieldStyle(for: [topTextField, bottomTextField])
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .systemTeal
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemTeal]
    }
    
    func setupImageView() {
        memeImageView.backgroundColor = .black
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
}




//MARK: Meme Image Handling
extension memeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getImageFrom(source: UIImagePickerController.SourceType) {
        returnAllTextFields()
        let pickerController = UIImagePickerController()
        pickerController.sourceType = source
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            memeImageView.image = image
        }
        setShareButton()
        dismiss(animated: true, completion: nil)
    }
}




//MARK: Meme Text Handling
extension memeViewController: UITextFieldDelegate {
    
    //Text Field Sytle & Text style
    func setMemeTextFieldStyle(for textFields: [UITextField]) {
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
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
}



//MARK: Meme Object Generation & Sharing
extension memeViewController {
    
    func generateMemedImage() -> UIImage {

        imageToolbar.isHidden = true
        navigationController?.navigationBar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        imageToolbar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        
        return memedImage
    }
    
    func saveMeme() {
        let currentMeme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, background: memeImageView.image!, memeImage: memeImage)
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
