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

___Step13___

###### 화면전환시 애니메이션 버그(시뮬레이터 Slow Animation)

버그가 발생했다.  

_첫번째 버그_
첫화면에서 Next 버튼을 누르면, 네비게이션 컨트롤러 고유의 push 애니메이션을 실행한다.  
그런데 화면이 넘어가면서, 첫화면의 요소들이 위로 올라가는 버그가 발생했다. 왜그럴까?  
  
이유는 이렇다.  
원활한 입력을 위해서 우리는 첫화면의 텍스트필드 키보드 타입 중 Correction과 Spell Checking값에 no를 지정해주었다.  
그리고 두번째 화면에서는 해당 키보드 타입 옵션을 해제하지 않았다. 즉, 두화면의 키보드 높이가 서로 다르다.  
그리고 노티피케이션을 해제하는 코드를 첫화면의 소멸자에 넣어두었다. 그러나, 두번째 화면에 push가 되더라도 deinit은 불리지 않는다.  
즉, 노티피케이션이 아직 해제되지 않았다는 말이다.  
  
그러면서 두번째화면의 keyboardWillShowNotification가 키보드 높이를 알리고, 그것을 구독하고 있는 두번째 화면의 메소드와 덩달아 첫번째 화면의 메소드까지 반응을 한 것이다. 키보드 높이가 달라졌으니 센터도 달라지고 결국 요소들이 push되면서 위로 올라가는 버그가 발생했다.    

###### 해결방안
```swift 

override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)

  tokens.forEach{
    NotificationCenter.default.removeObserver($0)
  }
}

```
  

노티피케이션 구독을 해제하는 코드를 viewWillDisappear 메소드에 집어넣는다.  
사실 내 첫 생각은 두번째화면의 viewDidLoad가 첫번쨰화면의 viewWillDisappear보다 미세하게 빨리 불리기 떄문에, 이게 해결되지 않을 줄 알았다.  
그러나 그 차이가 엄청나게 미세하고, 노피가 발생하고 첫번쨰 화면까지 오는 시간?이 있기 때문에 이 코드가 잘 동작하는 것 같다.  
그리고 이렇게 처리한 후, 문제가 전부다 해결 된 것처럼 보이지만 새로운 문제가 생긴다. 그것은 첫번째 뷰에서의 viewDidLoad는 메모리에 올라갈 때. 
한번만 불린다는 것이다. 즉 한번 화면을 갔다가 돌아오면 키보드 높이에 따른 애니메이션은 발생하지 않는다. 높이 또한 숏컷이 있는 키보드 높이를 유지한다.  
두번째 노티피케이션에서 발생한 값을 그대로 가지고 있는 것이다. 따라서 ___이 문제를 해결하려면 노티피케이션의 구독코드를 viewWillAppear로 옮겨주어야 한다.___
  
###### 두번째 버그  
  
두번째 화면에 들어갈때 밑에서부터 올라오는 애니메이션이 발생한다.  
순서는 이렇다. becomeFirstResponder를 해주면서 키보드 높이값이 전달되고, 그것에 따라서 애니메이션이 발생했다.  
  
###### 해결방안  
  
어떻게 해결할까? 해결방안은 이렇다. 두번째화면에 값을 받을 인스턴스를 선언하고, 첫화면에서 push하기 직전에 호출되는 메소드를 통해 키보드 높이값을 전달해준다. 그리고 그 값으로 viewDidLoad에서 높이값을 세팅해준다. 또한 미세한 애니메이션이 보일 수 있으므로 애니메이션을 없애주는 UIView.performWithoutAnimation {} 코드를 실행한다.  

```swift 

//키보드 높이를 전달, 화면이 전환되기 직전에 호출
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
if let vc = segue.destination as? EmailViewController {
vc.bottomMargin = bottomConstraint.constant
}
}

override func viewDidLoad() {
  super.viewDidLoad()
  print("viewDidLoad 2")

bottomConstraint.constant = bottomMargin ?? 0.0
  UIView.performWithoutAnimation {
    self.view.layoutIfNeeded()
  }
}
      
```

###### 문제점  
  
완벽한 해결책은 아니다. 왜냐하면 첫쨰뷰와 둘째뷰의 높이값이 다르기 때문이다. 첫째뷰는 키보드 숏컷바가 없다.  
따라서 높이값은 301인 반면에 둘째뷰는 346이다. 그래서 완벽한 해결을 하려면 둘째뷰의 숏컷바를 없애주거나 해야한다.  
하지만 또 숏컷바가 필요할 수 있으므로, 잘 선택해야 한다. 기기마다 키보드 높이값은 다를테니.  



___Step14___

###### 두번째뷰에서 되돌아올시에 팝애니메이션 실행 

이것도 어떻게보면 되게 디테일한?거다. 
뭐냐면, viewcontroller lifecycle에 viewDidAppear는 애니메이션 같은 것들을 그려준다. 그래서 보통 애니메이션 그리는 코드는 여기다가 넣는다. viewWillAppear에 넣으면 잘 동작하지 않는 경우가 많으므로. 

그런데 우리는 첫번째뷰가 실행될때 바로 키보드가 올라가게 하기 위해서, textFieldDidBeginEditing 메소드에서 UIView의 전체 애니메이션을 꺼줬다. 
그렇기 때문에 팝을 할때 네비게이션 고유의 애니메이션이 동작하지 않는 것이다. 그러면 어떻게 할까? 아래와 같이 변수를 하나 만들어줘서 처음 실행될 때만, 애니메이션이 꺼지게 지정해두면 된다. 만약에 뷰컨이 메모리에서 날아갔다면 presented 메소드 또한 다시 생성되었을 것이므로 동작에 지장이 없다. 

실제로 뷰가 로드되고, 델리게이트가 실행되고, 그 후에 viewDidAppear가 불리기도 한다. 

```swift 

var presented = false

 //텍스트필드에서 편집이 실행된 다음에 실행되는 메소드
func textFieldDidBeginEditing(_ textField: UITextField) {
    print("textFieldDidBeginEditing")
    //보통은 키보드가 애니메이션 없이 바로 올라오기 때문에 처리, 모든 애니메이션 비활성화
    if !presented {
        UIView.setAnimationsEnabled(false)
        presented = true
    }
}

```




