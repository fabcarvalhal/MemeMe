//
//  MemeCreatorViewController+UITextFieldDelegate.swift
//  MemeMe
//
//  Created by Fabrício Silva Carvalhal on 21/03/21.
//

import UIKit

extension MemeCreatorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
