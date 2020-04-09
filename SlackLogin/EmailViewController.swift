//
//  EmailViewController.swift
//  SlackLogin
//
//  Created by jongchankim on 2020/04/08.
//  Copyright © 2020 jongchankim. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController {
    
    var bottomMargin: CGFloat? //키보드 높이를 전달할 객체
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //노피티케이션 토큰을 저장하는 걸 선언하네?
    var tokens = [NSObjectProtocol]()
    
    
    //옵져버 제거
    deinit {
        print("deinit 2")

        tokens.forEach{
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear 2")

        
        emailField.becomeFirstResponder()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear 2")

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad 2")

        

        titleLabel.alpha = 0.0
        titleLabelBottomConstraint.constant = -20
        
        bottomConstraint.constant = bottomMargin ?? 0.0
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
        
        
        var token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] noti in
            if let frameValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
                let keyboardFrame = frameValue.cgRectValue
                print(keyboardFrame.size.height, "2222" )
                
                //전달된 높이값을 우선적으로 처리
                self?.bottomConstraint.constant = self?.bottomMargin ?? keyboardFrame.size.height
                
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                }) { (finished) in
                    
//                    UIView.setAnimationsEnabled(true)
                }
                
            }
        }
        
        tokens.append(token)
        
        
        token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            
            self?.bottomConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3) {
                self?.view.layoutIfNeeded()
            }
        })
        
        tokens.append(token)        
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
