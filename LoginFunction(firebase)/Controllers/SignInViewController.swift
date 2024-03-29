//
//  SignUpViewController.swift
//  LoginFunction(firebase)
//
//  Created by 강민석 on 2019/10/21.
//  Copyright © 2019 강민석. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var signUpEmailField: UITextField!
    @IBOutlet weak var signUpPwField: UITextField!
    
    @IBAction func signUpButton(_ sender: Any) {
        doSignUp()
    }
    
    @IBAction func movePrevious(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var tokens = [NSObjectProtocol]()
    
    override func viewWillAppear(_ animated: Bool) {
        signUpEmailField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tokens.forEach{ NotificationCenter.default.removeObserver($0) }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) {
            [weak self] (noti) in
            if let frameValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = frameValue.cgRectValue
                self?.bottomConstraint.constant = keyboardFrame.size.height
                
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                }, completion: { finished in
                    UIView.setAnimationsEnabled(true)
                })
            }
        }
        tokens.append(token)
        
        token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) {
            [weak self] (noti) in
            self?.bottomConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self?.view.layoutIfNeeded()
            })
        }
        tokens.append(token)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SignInViewController{

    func showAlert(message:String){
        let alert = UIAlertController(title: "회원가입 실패",message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default))
        self.present(alert, animated: true, completion: nil)
    }

    func doSignUp(){
        if signUpEmailField.text! == ""{
            showAlert(message: "이메일을 입력해주세요")
            return
        }
        if signUpPwField.text! == ""{
            showAlert(message: "비밀번호를 입력해주세요")
            return
        }
        signUp(email: signUpEmailField.text!, password: signUpPwField.text!)
    }

    func signUp(email:String,password:String){
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (user, error) in
            if error != nil{
                if let ErrorCode = AuthErrorCode(rawValue: (error?._code)!) {
                    switch ErrorCode {
                    case AuthErrorCode.invalidEmail:
                        self.showAlert(message: "유효하지 않은 이메일 입니다")
                    case AuthErrorCode.emailAlreadyInUse:
                        self.showAlert(message: "이미 가입한 회원 입니다")
                    case AuthErrorCode.weakPassword:
                        self.showAlert(message: "비밀번호는 6자리 이상이여야 합니다")
                    default:
                        print(ErrorCode)
                    }
                }
            } else{
                print("회원가입 성공")
                self.dismiss(animated: true)
                dump(user)
            }
        })
    }
}

// 참고 : https://eunjin3786.tistory.com/5
