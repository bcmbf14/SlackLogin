# SlackLogin


___배운점과 추가로 공부해야될 부분들 정리___

---

- Step1
  - [Textfield Inspector Keyboard attributes](https://developer.apple.com/documentation/uikit/uitextfield) 
    1. Correction : 엉뚱한 값이 입력되지 않도록 자동수정 옵션을 꺼주었다.
    2. Spell Checking : 엉뚱한 값이 입력되지 않도록 맞춤법 검사 옵션을 꺼주었다. 
    3. Keyboard Type : url을 입력하기 쉽도록 type을 url로 바꿔주었다.
    4. Return Key : 키보드 내의 return key를 go로 바꿔주어서 좀 더 명시적으로 보이게 한다. 

---

- Step5
  - 입력문자제한(캐릭터 셋 추가, 적용) 
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

---


- Step6
  - 텍스트 필드 호출 시점 : 아래 메소드에서 string을 프린트해보면 한글자씩 늦게 나오는 것을 볼 수 있다.
  ```swift 
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {}
  ```
  - 따라서, 최종텍스트를 찾아야 한다.
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
  - 그리고 입력된 텍스트 width만큼 leading으로 걸려있는 placeholder의 제약조건을 갱신해준다. 
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


- Step1
