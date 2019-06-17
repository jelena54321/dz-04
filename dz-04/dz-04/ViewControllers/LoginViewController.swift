//
//  LoginViewController.swift
//  dz-02
//
//  Created by Jelena Šarić on 09/05/2019.
//  Copyright © 2019 Jelena Šarić. All rights reserved.
//

import UIKit
import PureLayout

/// Class which presents view controller for login interface.
class LoginViewController: UIViewController {
    
    /// Central views container.
    private let viewsContainer: UIView = UIView()
    /// Application title.
    private let titleLabel: UILabel = UILabel()
    /// Username text field.
    private let usernameField: UITextField = UITextField()
    /// Password text field.
    private let passwordField: UITextField = UITextField()
    /// Login button.
    private let loginButton: UIButton = UIButton()
    /// Information label.
    private let infoLabel: UILabel = UILabel()
    
    /// Constraint which is expected to be modified.
    private var containerCenterYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpGUI()
        addTargets()
        addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateEverythingIn()
    }
    
    /**
     Tries to establish session with username and password currently stored
     as values in *usernameField* and *passwordField*.
    */
    @objc func loginTapped() {
        guard let username = usernameField.text,
              let password = passwordField.text else {
                return
        }
        
        LoginService.shared.establishSession(
            username: username,
            password: password)
            { [weak self] (userId, token) in
                if let userId = userId,
                   let token = token {
                    
                    UserDefaults.standard.set(userId, forKey: "userId")
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(username, forKey: "username")
                    
                    DispatchQueue.main.async {
                        self?.infoLabel.isHidden = true
                        
                        self?.animateEverythingOut() {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            appDelegate?.window?.rootViewController = TabBarViewController()
                        }
                    }
    
                } else {
                    DispatchQueue.main.async {
                        self?.passwordField.text = ""
                        self?.infoLabel.isHidden = false
                    }
                }
            }
    }
    
    /// Sets up graphic user interface.
    private func setUpGUI() {
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(viewsContainer)
        containerCenterYConstraint = viewsContainer.autoAlignAxis(.horizontal, toSameAxisOf: self.view)
        viewsContainer.autoAlignAxis(.vertical, toSameAxisOf: self.view)
        viewsContainer.autoPinEdge(.leading, to: .leading, of: self.view, withOffset: 40.0)
        viewsContainer.autoPinEdge(.trailing, to: .trailing, of: self.view, withOffset: -40.0)
        
        let defaultFont = UIFont.init(name: "Avenir-Book", size: 25.0)
        
        titleLabel.font = defaultFont
        titleLabel.text = "QuizApp"
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0.0
        
        self.view.addSubview(titleLabel)
        titleLabel.autoPinEdge(.top, to: .top, of: viewsContainer, withOffset: 20.0)
        titleLabel.autoMatch(.width, to: .width, of: viewsContainer)
        titleLabel.autoAlignAxis(.vertical, toSameAxisOf: self.view)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        usernameField.font = defaultFont
        usernameField.placeholder = "Username"
        usernameField.layer.borderColor = UIColor.lightGray.cgColor
        usernameField.layer.borderWidth = 1
        usernameField.layer.cornerRadius = 5
        usernameField.alpha = 0.0
        
        self.view.addSubview(usernameField)
        usernameField.autoPinEdge(.trailing, to: .leading, of: self.view)
        usernameField.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 20.0)
        usernameField.autoSetDimension(.height, toSize: 40.0)
        usernameField.autoMatch(.width, to: .width, of: viewsContainer)
        
        passwordField.font = defaultFont
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.layer.borderWidth = 1
        passwordField.layer.cornerRadius = 5
        passwordField.alpha = 0.0
        
        self.view.addSubview(passwordField)
        passwordField.autoPinEdge(.trailing, to: .leading, of: self.view)
        passwordField.autoPinEdge(.top, to: .bottom, of: usernameField, withOffset: 30.0)
        passwordField.autoSetDimension(.height, toSize: 40.0)
        passwordField.autoMatch(.width, to: .width, of: viewsContainer)
        
        loginButton.titleLabel?.font = defaultFont
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 5.0
        loginButton.backgroundColor = UIColor.init(
            red: 56.0/255.0,
            green: 148.0/255.0,
            blue: 1.0,
            alpha: 1.0
        )
        loginButton.alpha = 0.0
        
        self.view.addSubview(loginButton)
        loginButton.autoPinEdge(.trailing, to: .leading, of: self.view)
        loginButton.autoPinEdge(.top, to: .bottom, of: passwordField, withOffset: 40.0)
        loginButton.autoSetDimension(.height, toSize: 40.0)
        loginButton.autoMatch(.width, to: .width, of: viewsContainer)
        
        infoLabel.font = UIFont.init(name: "Avenir-Book", size: 15.0)
        infoLabel.text = "Incorrect username and/or password!"
        infoLabel.textAlignment = .center
        infoLabel.isHidden = true
        infoLabel.textColor = UIColor.lightGray
        
        self.view.addSubview(infoLabel)
        infoLabel.autoPinEdge(.leading, to: .leading, of: viewsContainer)
        infoLabel.autoPinEdge(.trailing, to: .trailing, of: viewsContainer)
        infoLabel.autoPinEdge(.top, to: .bottom, of: loginButton, withOffset: 10.0)
        infoLabel.autoPinEdge(.bottom, to: .bottom, of: viewsContainer, withOffset: -20.0)
        infoLabel.autoSetDimension(.height, toSize: 20.0)
    }
    
    /// Adds targets to views.
    private func addTargets() {
        loginButton.addTarget(
            self,
            action: #selector(LoginViewController.loginTapped),
            for: UIControl.Event.touchUpInside
        )
    }
    
    /// Sets up keyboard observers.
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    /**
     Defines action which will be executed once keyboard will appear. In this case,
     *fieldContainer*'s horizontal axis is lifted in order to avoid keyboard obscuring
     fields positioned inside of the container.
     
     - Parameters:
        - notification: object which presents keyboard event notification
    */
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = getKeyboardHeight(notification: notification) {
            containerCenterYConstraint.constant = -keyboardHeight / 2.0
            UIView.animate(withDuration: 0.5) { [weak self] () in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    /**
     Defines action which will be executed once keyboard will hide. In this case,
     *fieldContainer*'s horizontal axis is lowered in order to place container in
     it's initial position.
     
     - Parameters:
        - notification: object which presents keyboard event notification
    */
    @objc private func keyboardWillHide(notification: NSNotification) {
        containerCenterYConstraint.constant = 0.0
        UIView.animate(withDuration: 0.5) { [weak self] () in
            self?.view.layoutIfNeeded()
        }
    }
    
    /**
     Calculates keyboard's height from provided parameters.
     
     - Parameters:
        - notification: object which presents keyboard event notification
     
     - Returns: keyboard's height
    */
    private func getKeyboardHeight(notification: NSNotification) -> CGFloat? {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return keyboardFrame.cgRectValue.height
        }
        
        return nil
    }
    
    /// Animates all views in.
    private func animateEverythingIn() {
        let translateRight = CGAffineTransform(
            translationX: self.view.bounds.width - 40.0,
            y: 0.0
        )
        
        UIView.animate(withDuration: 0.5) {
            self.titleLabel.transform = CGAffineTransform(
                scaleX: 1,
                y: 1
            )
            self.titleLabel.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.usernameField.transform = translateRight
            self.usernameField.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.passwordField.transform = translateRight
            self.passwordField.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.5, delay: 1.0, animations: {
            self.loginButton.transform = translateRight
            self.loginButton.alpha = 1.0
        })
    }
    
    /// Animates all views out.
    private func animateEverythingOut(onComplete: @escaping (() -> Void)) {
        let translateUp = CGAffineTransform(
            translationX: 0,
            y: -self.view.bounds.height
        )
    
        UIView.animate(withDuration: 1) {
            self.titleLabel.transform = translateUp
            self.titleLabel.alpha = 0.0
        }
        
        UIView.animate(
            withDuration: 1,
            delay: 0.5, options:
            UIView.AnimationOptions.curveEaseInOut,
            animations: {
                self.usernameField.transform = translateUp
                self.titleLabel.alpha = 0.0
        })
        
        UIView.animate(
            withDuration: 1,
            delay: 1.0,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                self.passwordField.transform = translateUp
                self.titleLabel.alpha = 0.0
        })
        
        UIView.animate(
            withDuration: 1,
            delay: 1.5,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
                self.loginButton.transform = translateUp
                self.titleLabel.alpha = 0.0
        }) { _ in
            onComplete()
        }
    }

}
