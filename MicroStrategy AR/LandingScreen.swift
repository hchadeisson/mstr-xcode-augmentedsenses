//
//  LandingScreen.swift
//  ARKitImageRecognition
//
//  Created by Chadeisson, Henri-Francois on 5/28/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit

class LandingScreen: UIViewController, UITextFieldDelegate
{
	@IBOutlet weak var userLogin: UITextField!
	@IBOutlet weak var userPassword: UITextField!
	@IBOutlet weak var baseUrlLabel: UILabel!
	
	var baseUrl = "https://tutorial.microstrategy.com/MicroStrategyLibrary/api"
	var cartDossierUrl = "dossier://?url=https://tutorial.microstrategy.com/MicroStrategyLibrary/app/00DA0E434629817E141757A44F6FF5CE/3ABF647611E862B6D2F40080EF854718"
	var smartBotUrl = "https://webchat.innaas.com/MSTR_HCHADEISSON-AugmentedSenses/chat"
	var projectId = "00DA0E434629817E141757A44F6FF5CE"
	var datasetId = "FB085E9E11E8C65DAD000080EF057F6A"
	var loanDurationAttr = "FA432E4411E8C65DBCDC0080EFD59FAA"
	var itemAttr = "FA431A6C11E8C65D402D0080EFD59FAA"
	var userNameAttr = "FA43131411E8C65D402D0080EFD59FAA"
	
	var RESTUser = mstrRestApiClass()
	var cart = cartClass()
	let defaults = UserDefaults.standard

	override func viewDidLoad()
	{
		let user = self.defaults.object(forKey: "userLogin")
		let pass = self.defaults.object(forKey: "userPassword")
		self.userLogin.delegate = self
		self.userPassword.delegate = self
		if user != nil
		{
			self.userLogin.text = user as? String
		}
		if user != nil
		{
			self.userPassword.text = pass as? String
		}
		self.baseUrlLabel.text = self.baseUrl
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		// Try to find next responder
		if textField.accessibilityIdentifier == "username"
		{
			self.userLogin.resignFirstResponder()
			self.userPassword.becomeFirstResponder()
		}
		else
		{
			self.performSegue(withIdentifier: "LandingScreen", sender: self)
		}
		return false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "LandingScreen"
		{
			self.RESTUser.setUserName(userName: self.userLogin.text!)
			self.RESTUser.setPassword(password: self.userPassword.text!)
			let controller = segue.destination as! ViewController
			self.RESTUser.setBaseUrl(baseUrl: self.baseUrl)
			self.RESTUser.Authentication_postAuthLogin(password: self.RESTUser.getPassword(), loginMode: 16)
			self.RESTUser.setProjectId(projectId: self.projectId)
			self.RESTUser.setDatasetId(datasetId: self.datasetId)
			controller.RESTUser = self.RESTUser
			self.cart.setEnv(loanDurationAttr: self.loanDurationAttr, itemAttr: self.itemAttr, userNameAttr: self.userNameAttr, cartDossierUrl: self.cartDossierUrl, smartBotUrl: self.smartBotUrl)
			controller.cart = self.cart
		}
	}
	
}
