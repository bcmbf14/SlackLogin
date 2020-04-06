//
//  ViewController.swift
//  SlackLogin
//
//  Created by jongchankim on 2020/04/07.
//  Copyright © 2020 jongchankim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let charSet:CharacterSet = {
        var cs = CharacterSet.lowercaseLetters
        cs.insert(charactersIn: "0123456789")
        cs.insert(charactersIn: "-")
        return cs.inverted
    }()

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    
}



extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //range 편집된범위
        
        //입력모드에서만 실행
        if string.count > 0 {
            //문자열에서 캐릭터셋에 포함된 문자를 검색한다.
            //포함되었으면 해당범위를 리턴, 아니면 닐을 리턴
            //가드문을 썼으므로 charSet만 입력이 가능하도록 강제 세팅
            guard string.rangeOfCharacter(from: charSet) == nil else { return false }
        }
        
        let finalText = NSMutableString(string: textField.text ?? "")
        finalText.replaceCharacters(in: range, with: string)
        
        let font = textField.font ?? UIFont.systemFont(ofSize: 16)
        
        let dict = [NSAttributedString.Key.font: font]
        
        let width = finalText.size(withAttributes: dict).width
        
        placeholderLeadingConstraint.constant = width
        
        if finalText.length == 0 {
            placeholderLabel.text = "workspace-url.slack.com"
        }else{
            placeholderLabel.text = ".slack.com"
        }
        
        return true
    }
    
}
