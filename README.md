# SlackLogin


___배운점과 추가로 공부해야될 부분들 정리___

# 

___Step1___
  
###### [Textfield Inspector Keyboard attributes](https://developer.apple.com/documentation/uikit/uitextfield) 
    
- Correction : 엉뚱한 값이 입력되지 않도록 자동수정 옵션을 꺼주었다.
- Spell Checking : 엉뚱한 값이 입력되지 않도록 맞춤법 검사 옵션을 꺼주었다. 
- Keyboard Type : url을 입력하기 쉽도록 type을 url로 바꿔주었다.
- Return Key : 키보드 내의 return key를 go로 바꿔주어서 좀 더 명시적으로 보이게 한다. 

# 

___Step5___
###### 입력문자제한(캐릭터 셋 추가, 적용)

  ```swift
    //캐릭터셋을 만들어줘서 내가 원하는 문자만 받을 수 있다.
    //입력하는 것중에서 내가 원하는 것을 검색해서 그게 아니면 안들어오게 해주고 있는데,
    //그게 더 효율적이라서 그렇게 해준댄다.
    let charSet:CharacterSet = {
        var cs = CharacterSet.lowercaseLetters
        cs.insert(charactersIn: "0123456789")
        cs.insert(charactersIn: "-")
        return cs.inverted
    }()
    
  ```
  
  ```swift
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //range 편집된범위
        
        //입력모드에서만 실행
        if string.count > 0 {
            //문자열에서 캐릭터셋에 포함된 문자를 검색한다.
            //포함되었으면 해당범위를 리턴, 아니면 닐을 리턴
            //가드문을 썼으므로 charSet만 입력이 가능하도록 강제 세팅
            guard string.rangeOfCharacter(from: charSet) == nil else { return false }
        }
  }
  
  ```

# 


___Step6___
###### 텍스트 필드 호출 시점 : 아래 메소드에서 string을 프린트해보면 한글자씩 늦게 나오는 것을 볼 수 있다.  
  ```swift 
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {}
  ```
###### 따라서, 최종텍스트를 찾아야 한다.
  ```swift
  //그 텍필찍어보면 한글자씩 늦게나오잖아. 그래서 그거 해결하려고 마지막 텍스트 가져오는거야.
  //그리고 현재사이즈같은거 정확하게 갖고오기 편하려고 NSMutableString으로 만든거래.
  let finalText = NSMutableString(string: textField.text ?? "")
  finalText.replaceCharacters(in: range, with: string)

  //현재 폰트가져오고
  let font = textField.font ?? UIFont.systemFont(ofSize: 16)

  let dict = [NSAttributedString.Key.font: font]

  //현재 폰트 기준으로 정확한 너비를 가져온다.
  let width = finalText.size(withAttributes: dict).width
   ```
###### 그리고 입력된 텍스트 width만큼 leading으로 걸려있는 placeholder의 제약조건을 갱신해준다. 
  ```swift
  //그리고 그 너비만큼 밀어준다.
  placeholderLeadingConstraint.constant = width

  if finalText.length == 0 {
      placeholderLabel.text = "workspace-url.slack.com"
  }else{
      placeholderLabel.text = ".slack.com"
  }

  nextButton.isEnabled = finalText.length > 0
  
  ```
# 

___Step7___
###### 옵저버 등록 : 옵저버를 등록하는데 약간 특이하더라고? 괜찮은거같애. 
  ```swift
   //옵저버 생성 
   //노피티케이션 토큰을 저장하는 걸 선언하네?
    var tokens = [NSObjectProtocol]()
    
    //옵져버 제거
    deinit {
        tokens.forEach{
            NotificationCenter.default.removeObserver($0)
        }
    }
  ```
  
  ```swift
  //옵저버 등록 
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
```    
###### Container Patten :  
    이건 뭐냐면, 키보드 높낮이를 조절할 때 제약조건을 어떤 레이블이나 텍스트필드 등을 감싸고 있는 컨테이너뷰에 거는거야.  
    그렇게하면 컨테이너 필드가 올라갈 때, 컨테이너 안에있는 뷰들의 제약조건도 자동으로 변경이 되서 UI를 구성하기 편하다는거지.  
    예를들어보면, 난 이제까지 view.origin.frame.y += keyboardheight 이런식으로 처리를 했었어.  
    근데 이 프로젝트의 좋은게 뭐냐면 컨테이너뷰에 제약조건을 걸어줬을때, 텍필같은경우는 컨테이너의 센터y값으로 높이를 지정해줬단 말이야?  
    그래서 origin으로 했을땐 키보드높이가 150이면 전체가 그대로 150이 올라갔는데,  
    이녀석 같은 경우는 키보드 높이가 150이 올라간 그 후에 남아있는 컨테이너뷰의 높이를 기준으로 centerY의 위치로 텍스트필드가 이동하더라고.  
    그래서 훨씬 보기 좋더라고. 
  
###### 키보드 애니메이션 상황에 따른 활성화/비활성화 
    ```swift
    
     override func viewDidLoad() {
        super.viewDidLoad()
    
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
    ```
# 
