//
//  ComprasTableViewController.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 04/07/21.
//
import Firebase
import UIKit

class ComprasTableViewController: UITableViewController, OptionButtonsDelegate, UITextFieldDelegate {
    
    //tela
    @IBOutlet weak var navBar: UINavigationItem!
    
    //globais
    let auth = Auth.auth();
    let db = Firestore.firestore();
    var listaCompras : [Dictionary<String, Any>] = [];
    var btn = UIButton(type: .custom);
    var idLogado        : String!;
    var idParceiro      : String = "";
    var comprasListener : ListenerRegistration!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        floatingButton();
        addBackground();
        
        tableView.delegate = self;
        
        if let id = auth.currentUser?.uid{
            idLogado = id;
        }
        
        db.collection("usuarios").document(self.idLogado).collection("group").getDocuments { querySnap, error in
            if let data = querySnap{
                for item in data.documents{
                    let user = item.data();
                    self.idParceiro = user["id"] as! String;
                }
            }
        }
        //nome na navbar
        db.collection("usuarios").document(self.idLogado).getDocument { querySnap, error in
            if let data = querySnap{
                let item = data.data();
                self.navBar.title = item!["nome"] as? String;
            }
        }
        
        navBar.setHidesBackButton(true, animated: false);
        
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        self.tableView.allowsSelection = false;
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let lines = listaCompras.count;
        return lines;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath) as! ComprasTableViewCell;
        cell.delegate = self;
        
        let dados = self.listaCompras[indexPath.row];
        let itemCompra = dados["descricao"] as? String;
        let finalizado = dados["finalizado"] as? String;

        if finalizado == "false"{
            cell.btnCheck.isHidden = false;
            cell.btnChecked.isHidden = true;
        } else if finalizado == "true"{
            cell.btnCheck.isHidden = true;
            cell.btnChecked.isHidden = false;
        }
            
        
        cell.lblItem.text = itemCompra;
        cell.indexPath = indexPath;
        
        return cell
    }

    func btnTapped(at index: IndexPath){
        
        print("Clicou aqui \(index.row)");
        var item = listaCompras[index.row];
        if item["finalizado"] as? String == "false"{
            item["finalizado"] = "true";
        } else {
            item["finalizado"] = "false";
        }
        db.collection("compras").document(idLogado).collection("compra").document((item["descricao"] as? String)!).setData(item);
        
        if self.idParceiro != ""{
            db.collection("compras").document(idParceiro).collection("compra").document((item["descricao"] as? String)!).setData(item);
        }
        
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: {a,b,c in
            
            // delete function
            let item = self.listaCompras[indexPath.row];
            let itemDel = item["descricao"] as! String;
            
            self.listaCompras.remove(at: indexPath.row);
            tableView.deleteRows(at: [indexPath], with: .automatic);
            
            self.db.collection("compras").document(self.idLogado).collection("compra").document(itemDel).delete();
            if self.idParceiro != ""{
                self.db.collection("compras").document(self.idParceiro).collection("compra").document(itemDel).delete();
            }
            
        })
     
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor(cgColor: CGColor(srgbRed: 125 / 255, green: 226 / 255, blue: 209 / 255, alpha: 1))
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    

    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  off = self.tableView.contentOffset.y

        btn.frame = CGRect(x: self.view.frame.size.width - (btn.frame.size.width + 16), y:   off + self.view.frame.size.height - (btn.frame.size.height + 16), width: btn.frame.size.width, height: btn.frame.size.height)
    }
    
    func floatingButton(){
        btn.frame = CGRect(x: 285, y: 485, width: 100, height: 100)
        btn.setImage(UIImage(named: "btnPlus"), for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 50
        btn.layer.borderColor = CGColor(red: 52 / 255, green: 153 / 255, blue: 137 / 255, alpha: 1)
        btn.addTarget(self,action: #selector(adicionar), for: .touchUpInside)
        
        tableView.addSubview(btn)
    }
    
    @objc func adicionar(){
        let newItem =  UITextField(frame: CGRect(x: 20, y: 20, width: 300, height: 48))
        newItem.placeholder = "Digite o novo item aqui"
        newItem.font = UIFont.systemFont(ofSize: 15)
        newItem.borderStyle = UITextField.BorderStyle.roundedRect
        newItem.autocorrectionType = UITextAutocorrectionType.no
        newItem.keyboardType = UIKeyboardType.default
        newItem.returnKeyType = UIReturnKeyType.done
        newItem.clearButtonMode = UITextField.ViewMode.whileEditing
        newItem.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        newItem.delegate = self
        self.view.addSubview(newItem);
        newItem.becomeFirstResponder();
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != ""{
            
            let itemList : Dictionary<String , Any> = [
                "descricao": textField.text!,
                "finalizado": "false"
            ]
            
            db.collection("compras").document(idLogado).collection("compra").document(textField.text!).setData(itemList);
            db.collection("compras").document(idParceiro).collection("compra").document(textField.text!).setData(itemList);
            
            textField.isHidden = true;
        }else{
            textField.isHidden = true;
        }
    }
    
    func addBackground() {

        // 295 is the size of the pic
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: -100, width: tableView.frame.size.width, height: tableView.frame.size.height));
        imageViewBackground.image = UIImage(named: "fundo");
        imageViewBackground.alpha = 0.6;

        imageViewBackground.contentMode = UIView.ContentMode.bottomLeft;

        tableView.addSubview(imageViewBackground);
        tableView.sendSubviewToBack(imageViewBackground);
    
    }
    
    func recuperarListaCompras(){
        comprasListener = db.collection("compras").document(self.idLogado).collection("compra").addSnapshotListener({ querySnap, error in
            self.listaCompras.removeAll();
            
            if let snapShot = querySnap{
                for document in snapShot.documents{
                    let dados = document.data();
                    self.listaCompras.append(dados);
                }
                self.tableView.reloadData();
                print(self.listaCompras);
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recuperarListaCompras();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false);
        navBar.setHidesBackButton(true, animated: false);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        comprasListener.remove();
        navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    @IBAction func apagarConcluidos(_ sender: Any) {
        print("apagar Concluidos");
        
        for item in listaCompras{
            if item["finalizado"] as! String == "true"{
                print("aqui")
                self.db.collection("compras").document(self.idLogado).collection("compra").document(item["descricao"] as! String).delete();
                if self.idParceiro != ""{
                    self.db.collection("compras").document(self.idParceiro).collection("compra").document(item["descricao"] as! String).delete();
                }
            }
        }
        
    }
    
}
