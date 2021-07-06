//
//  CadastroViewController.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 02/07/21.
//

import UIKit
import Firebase

class CadastroViewController: UIViewController, UITextFieldDelegate {

    //tela
    @IBOutlet weak var txtNome: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirmation: UITextField!
    @IBOutlet weak var btnCadastrar: UIButton!
    
    //globais
    let auth = Auth.auth();
    let db   = Firestore.firestore();
    var keyboardChanger = Timer();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegarTxt();
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtNome{
            keyboardChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
                self.txtUser.becomeFirstResponder();
            });
        } else if textField == self.txtUser{
            keyboardChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
                self.txtPass.becomeFirstResponder();
            });
        }  else if textField == self.txtPass{
            keyboardChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
                self.txtConfirmation.becomeFirstResponder();
            });
        } else if textField == self.txtConfirmation{
            keyboardChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
                self.btnCadastrar.becomeFirstResponder();
            });
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false);
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    @IBAction func cadastrar(_ sender: Any) {
        //verificar preenchimento (ainda não acredito que essa coisa horrível é a "melhor prática" em swift)
        if self.txtNome.text != ""{
            if let nome = txtNome.text{
                if self.txtUser.text != ""{
                    if let user = txtUser.text {
                        if txtPass.text != ""{
                            if let pass = txtPass.text{
                                if txtConfirmation.text != ""{
                                    if let confirmation = txtConfirmation.text{
                                        if pass == confirmation{
                                            // campos preenchidos;)
                                            auth.createUser(withEmail: user, password: pass) { result, error in
                                                if error != nil{
                                                    let erroTratavel = error! as NSError;
                                                    if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_INVALID_EMAIL" { //nao eh email
                                                        let alerta = Alerta.init(titulo: "", mensagem: "e-mail informado não é válido").getCancelar();
                                                        self.present(alerta, animated: false, completion: nil);
                                                        
                                                    } else if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_WEAK_PASSWORD"{
                                                        let alerta = Alerta.init(titulo: "", mensagem: "a senha está fraca, precisamos de uma senha com 6 caracteres").getCancelar();
                                                        self.present(alerta, animated: false, completion: nil);
                                                        
                                                    } else if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_EMAIL_ALREADY_IN_USE"{
                                                        let alerta = Alerta.init(titulo: "", mensagem: "e-mail já cadastrado no sistema").getCancelar();
                                                        self.present(alerta, animated: false, completion: nil);
                                                    } else {
                                                        let alerta = Alerta.init(titulo: "", mensagem: "ocorreu um erro interno ao cadastrar o usuário").getCancelar();
                                                        self.present(alerta, animated: false, completion: nil);
                                                    }
                                                    print(erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"]!);
                                                    
                                                }else{
                                                    //sucesso, cadastrar no firestore
                                                    if let idUser = result?.user.uid{
                                                        self.db.collection("usuarios").document(idUser).setData([
                                                            "nome": nome,
                                                            "email": user,
                                                            "id": idUser
                                                        ]);
                                                    }
                                                }
                                            }
                                            
                                        }else {
                                            let alerta = Alerta(titulo: "", mensagem: "sua senha e confirmação estão diferentes, por favor verifique").getCancelar();
                                            self.present(alerta, animated: true, completion: nil);
                                        }
                                    }
                                } else{
                                    let alerta = Alerta(titulo: "", mensagem: "por favor, informe a confirmação da sua senha").getCancelar();
                                    self.present(alerta, animated: true, completion: nil);
                                }
                            }
                        } else{
                            let alerta = Alerta(titulo: "", mensagem: "por favor, informe o sua senha").getCancelar();
                            self.present(alerta, animated: true, completion: nil);
                        }
                    }
                    
                }else{
                    let alerta = Alerta(titulo: "", mensagem: "por favor, informe o seu e-mail").getCancelar();
                    self.present(alerta, animated: true, completion: nil);
                }
            }
        } else{
            let alerta = Alerta(titulo: "", mensagem: "por favor, informe o seu nome").getCancelar();
            self.present(alerta, animated: true, completion: nil);
        }
        
    }
    
    func delegarTxt(){
        self.txtNome.delegate = self;
        self.txtUser.delegate = self;
        self.txtPass.delegate = self;
        self.txtConfirmation.delegate = self;
    }
}
