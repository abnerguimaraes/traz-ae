//
//  ContatosViewController.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 03/07/21.
//
import UIKit
import Firebase

class ContatosViewController: UIViewController {

    //tela
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var txtContato: UITextField!
    @IBOutlet weak var btnCadastrar: UIButton!
    
    //globais
    let auth = Auth.auth();
    let db = Firestore.firestore();
    var idLogado: String!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if auth.currentUser?.uid != nil{
            idLogado = auth.currentUser?.uid;
        }
        
    }

    @IBAction func cadastrar(_ sender: Any) {
        if let contato = txtContato.text{
            if contato == ""{
                lblError.text = "informe o e-mail do contato";
            } else if contato == auth.currentUser?.email{
                lblError.text = "você está tentando incluir você mesmo ;p"
            } else {
                
                db.collection("usuarios").whereField("email", isEqualTo: contato).getDocuments { querySnapshot, error in
                    if let totalItens = querySnapshot?.count{
                        if totalItens == 0{
                            self.lblError.text = "usuário não localizado na base";
                        }else{
                            self.db.collection("usuarios").document(self.idLogado).collection("group").getDocuments { result, error in
                                if error == nil{
                                    if let data = result{
                                        if data.count == 0 {
                                            
                                            if let dataAssocia = querySnapshot{
                                                for item in dataAssocia.documents{
                                                    let salveData = item.data();
                                                    self.salvarDados(dados: salveData);
                                                }
                                            }
                                            
                                        } else {
                                            self.lblError.text = "usuário já associado a um grupo";
                                            self.txtContato.isEnabled = false;
                                            self.btnCadastrar.isEnabled = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func salvarDados(dados: Dictionary<String, Any>){
        let primaryKey = dados["id"];
        
        //me incluindo no usuário
        db.collection("usuarios").getDocuments { querySnapshot, error in
            if let data = querySnapshot{
                for item in data.documents{
                    let salveData = item.data();
                    self.db.collection("usuarios").document(primaryKey as! String).collection("group").document(self.idLogado).setData(salveData);
                    print(salveData);
                }
            }
        }
        
        //self.db.collection("usuarios").document(primaryKey as! String).collection("group").document(self.idLogado).setData(salveData);
        
        //incluindo usuário no meu grupo
        db.collection("usuarios").document(self.idLogado).collection("group").document(primaryKey as! String).setData(dados);
        
    }
    
    @IBAction func sair(_ sender: Any) {
        
        do
            { try auth.signOut();
        }catch{

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
}
