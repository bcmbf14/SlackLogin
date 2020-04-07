//
//  ViewController.swift
//  SlackLogin
//
//  Created by jongchankim on 2020/04/07.
//  Copyright © 2020 jongchankim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //캐릭터셋을 만들어줘서 내가 원하는 문자만 받을 수 있다.
    //입력하는 것중에서 내가 원하는 것을 검색해서 그게 아니면 안들어오게 해주고 있는데,
    //그게 더 효율적이라서 그렇게 해준댄다.
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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //노피티케이션 토큰을 저장하는 걸 선언하네?
    var tokens = [NSObjectProtocol]()
    
    
    //옵져버 제거
    deinit {
        tokens.forEach{
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        urlField.becomeFirstResponder()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
         
        
        var token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] noti in
            if let frameValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
                let keyboardFrame = frameValue.cgRectValue
                print(keyboardFrame)
                
                self?.bottomConstraint.constant = keyboardFrame.size.height
                
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                    print("11")
                }) { (finished) in
                    //그니까 하고싶은건 이거야.
                    //화면실행하자마자 키보드가 첫응답을 한상태여야 해서 becomeFirstResponder를 했어.
                    //근데, 보통 애니메이션 없이 바로 올라와있는 상태가 일반적이라
                    //textFieldDidBeginEditing에서 전체 애니메이션을 해제해줬어.
                    //그리고 화면이 로드가 다 되고 난후에(viewWillAppear이후에 viewDidLoad가 실행되니까)
                    //다시 애니메이션을 활성화시켜줘야 하잖아.
                    //여기 애니메이션을 걸어놓는다고 바로 실행이되는게아니라, 이미 노티를 등록할때 세팅이 되는거야.
                    //그래서 애니메이션이 등록?되면서 컴플리션으로 다시 애니메이션을 활성화시켜주는거지
                    UIView.setAnimationsEnabled(true)
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

    
}



extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let cnt = textField.text?.count ?? 0
        
        if cnt > 0 {
            performSegue(withIdentifier: "emailSegue", sender: nil)
        }
        
        return true
    }
    
    
    //텍스트필드에서 편집이 실행된 다음에 실행되는 메소드
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //보통은 키보드가 애니메이션 없이 바로 올라오기 때문에 처리, 모든 애니메이션 비활성화
        UIView.setAnimationsEnabled(false)
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //range 편집된범위
        
        //입력모드에서만 실행
        if string.count > 0 {
            //문자열에서 캐릭터셋에 포함된 문자를 검색한다.
            //포함되었으면 해당범위를 리턴, 아니면 닐을 리턴
            //가드문을 썼으므로 charSet만 입력이 가능하도록 강제 세팅
            guard string.rangeOfCharacter(from: charSet) == nil else { return false }
        }
        
        //그 텍필찍어보면 한글자씩 늦게나오잖아. 그래서 그거 해결하려고 마지막 텍스트 가져오는거야.
        //그리고 현재사이즈같은거 정확하게 갖고오기 편하려고 NSMutableString으로 만든거래.
        let finalText = NSMutableString(string: textField.text ?? "")
        finalText.replaceCharacters(in: range, with: string)
        
        //현재 폰트가져오고
        let font = textField.font ?? UIFont.systemFont(ofSize: 16)
        
        let dict = [NSAttributedString.Key.font: font]
        
        //현재 폰트 기준으로 정확한 너비를 가져온다.
        let width = finalText.size(withAttributes: dict).width
        
        //그리고 그 너비만큼 밀어준다.
        placeholderLeadingConstraint.constant = width
        
        if finalText.length == 0 {
            placeholderLabel.text = "workspace-url.slack.com"
        }else{
            placeholderLabel.text = ".slack.com"
        }
        
        nextButton.isEnabled = finalText.length > 0
        
        return true
    }
    
}
