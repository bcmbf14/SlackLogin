//
//  EmailViewController.swift
//  SlackLogin
//
//  Created by jongchankim on 2020/04/08.
//  Copyright © 2020 jongchankim. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.alpha = 0.0
        titleLabelBottomConstraint.constant = -20
    }
    
    @IBAction func movePrevious(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}


extension EmailViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        placeholderLabel.alpha = (textField.text ?? "").count > 0 ? 0.0 : 1.0
        return true //입력허용,안허용
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalText = NSMutableString(string: textField.text ?? "")
        finalText.replaceCharacters(in: range, with: string)
        
        placeholderLabel.alpha = finalText.length > 0 ? 0.0 : 1.0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.titleLabel.alpha = finalText.length > 0 ? 1.0 : 0.0
            self?.titleLabelBottomConstraint.constant = finalText.length > 0 ? 0 : -20
            
            self?.view.layoutIfNeeded()
        }
        
        
        return true
    }
    
    
}
