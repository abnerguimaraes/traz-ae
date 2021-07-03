//
//  Alerta.swift
//  traz-ae
//
//  Created by Abner Thiago da Silva Guimarães on 02/07/21.
//
import Foundation
import UIKit;

class Alerta{
    
    var titulo: String;
    var mensagem: String;
    
    init(titulo: String, mensagem: String) {
        self.titulo = titulo;
        self.mensagem = mensagem;
    }
    
    func getCancelar() -> UIAlertController {
        
        let alerta = UIAlertController(title: self.titulo, message: self.mensagem, preferredStyle: .actionSheet);
        let acaoCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil);
        
        alerta.addAction(acaoCancelar);
        
        return alerta;
        
    }
    
    func getOkCancelar(callback: UIAlertAction) -> UIAlertController {
        
        let alerta = UIAlertController(title: self.titulo, message: self.mensagem, preferredStyle: .actionSheet);
        let acaoCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil);
       
        alerta.addAction(acaoCancelar);
        alerta.addAction(callback);
        
        return alerta;
        
    }
    
}
