//
//  Session.swift
//  MuscleFoods
//
//  Created by 庄野響 on 2020/01/09.
//  Copyright © 2020 Hibimaru. All rights reserved.
//

//
//  SessionStore.swift
//  SwiftUISignIn
//
//  Created by 庄野響 on 2019/12/18.
//  Copyright © 2019 Hibimaru. All rights reserved.
//

import SwiftUI
import Firebase
import Combine

class SessionStore: ObservableObject {
    var msg = ""
    var pop = false
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var session: User? {
        didSet {self.didChange.send(self) }
    }
    var handle: AuthStateDidChangeListenerHandle?
    
    //認証状態をリッスンする
    func listen() {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.session = User(uid: user.uid, email: user.email)
            } else {
                self.session = nil
            }
        })
    }
    //新しいユーザーを登録する
    func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                self.msg = "\(err!.localizedDescription)"
                self.pop.toggle()
            }
        }
    }
    //サインインする
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                self.msg = "\(err!.localizedDescription)"
                self.pop.toggle()
            }
        }
    }
    //サインアウトする
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch {
            print("Error signing out")
        }
    }
    //デタッチする
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    deinit {
        unbind()
    }
}


struct User {
    var uid: String
    var email: String?
    
    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }
    
}

