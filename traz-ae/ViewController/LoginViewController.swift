//
//  LoginViewController.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 02/07/21.
//
import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    //tela
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblSenha: UILabel!
    @IBOutlet weak var txtSenha: UITextField!
    @IBOutlet weak var btnEntrar: UIButton!
    
    //globais
    var keyboardChanger = Timer();
    var auth            = Auth.auth();
    var handleLogado    : AuthStateDidChangeListenerHandle!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //retirar o logoff automatico
        do
            { try auth.signOut();
        }catch{
            print("teste")
        }
        
        
        handleLogado = auth.addStateDidChangeListener({ auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginAutomatico", sender: nil);
            }
        })
        
        navigationController?.setNavigationBarHidden(true, animated: false);
    
        inicializacaoVisualCampos();
    
        self.txtEmail.delegate = self;
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged);
        
        self.txtSenha.delegate = self
        self.txtSenha.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    
    func inicializacaoVisualCampos() {
        lblEmail.isHidden = true;
        lblSenha.isHidden = true;
    }
    
    
    func tiraBorda(textField: UITextField){
        if textField == self.txtEmail{
            let bottomLineMail = CALayer();
            bottomLineMail.frame = CGRect(x: 0, y: self.txtEmail.frame.height - 1, width: self.txtEmail.frame.width, height: 1.0);
            bottomLineMail.backgroundColor = UIColor.systemGray4.cgColor
            self.txtEmail.borderStyle = UITextField.BorderStyle.none;
            self.txtEmail.layer.addSublayer(bottomLineMail);
        }
        
        if textField == self.txtSenha{
            let bottomLinePass = CALayer();
            bottomLinePass.frame = CGRect(x: 0, y: self.txtSenha.frame.height - 1, width: self.txtSenha.frame.width, height: 1.0);
            bottomLinePass.backgroundColor = UIColor.systemGray4.cgColor;
            self.txtSenha.borderStyle = UITextField.BorderStyle.none;
            self.txtSenha.layer.addSublayer(bottomLinePass);
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtEmail{
            print("mail");
            let bottomLineMail = CALayer();
            bottomLineMail.frame = CGRect(x: 0, y: self.txtEmail.frame.height - 1, width: self.txtEmail.frame.width, height: 1.0);
            bottomLineMail.backgroundColor = UIColor.darkGray.cgColor
            self.txtEmail.borderStyle = UITextField.BorderStyle.none;
            self.txtEmail.layer.addSublayer(bottomLineMail);
        }
           
        if textField == self.txtSenha{
            print("Senha");
            let bottomLinePass = CALayer();
            bottomLinePass.frame = CGRect(x: 0, y: self.txtSenha.frame.height - 1, width: self.txtSenha.frame.width, height: 1.0);
            bottomLinePass.backgroundColor = UIColor.darkGray.cgColor;
            self.txtSenha.borderStyle = UITextField.BorderStyle.none;
            self.txtSenha.layer.addSublayer(bottomLinePass);
        }
    }
    
    @objc func textFieldDidChange(sender: Any){
        if txtEmail.text != ""{
            lblEmail.isHidden = false;
        } else{
            lblEmail.isHidden = true;
        }
        if txtSenha.text != ""{
            lblSenha.isHidden = false;
        } else{
            lblSenha.isHidden = true;
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtEmail{
            keyboardChanger = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
                self.txtSenha.becomeFirstResponder();
            })
            
        } else if textField == self.txtSenha{
            self.btnEntrar.becomeFirstResponder();
        }
        tiraBorda(textField: textField);
    }
    
    @IBAction func entrar(_ sender: Any) {
    
        if txtEmail.text != ""{
            if let user = txtEmail.text{
                if txtSenha.text != "" {
                    if let pass = txtSenha.text{
                        auth.signIn(withEmail: user, password: pass) { authResult, error in
                            
                            if error != nil{
                                let erroTratavel = error! as NSError;
                                if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_INVALID_EMAIL" { //nao eh email
                                    let alerta = Alerta.init(titulo: "", mensagem: "e-mail informado não é válido").getCancelar();
                                    self.present(alerta, animated: false, completion: nil);
                                    
                                } else if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_USER_NOT_FOUND"{
                                    let alerta = Alerta.init(titulo: "", mensagem: "usuário não cadastrado em nossas bases").getCancelar();
                                    self.present(alerta, animated: false, completion: nil);
                                    
                                } else if erroTratavel.userInfo["FIRAuthErrorUserInfoNameKey"] as! String == "ERROR_WRONG_PASSWORD"{
                                    let alerta = Alerta.init(titulo: "", mensagem: "a informada senha não é válida").getCancelar();
                                    self.present(alerta, animated: false, completion: nil);
                                    
                                }
                            }
                        }
                    }
                } else{
                    let alerta = Alerta.init(titulo: "", mensagem: "Informe a sua senha").getCancelar();
                    self.present(alerta, animated: false, completion: nil);
                }
            }
        } else{
            let alerta = Alerta.init(titulo: "", mensagem: "Informe o seu e-mail").getCancelar();
            self.present(alerta, animated: false, completion: nil);
        }
    }
    
}
