//
//  CadastroViewController.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 02/07/21.
//

import UIKit

class CadastroViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true);
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
}
