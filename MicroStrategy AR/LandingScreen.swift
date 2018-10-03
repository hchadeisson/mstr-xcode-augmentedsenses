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
	var RESTUser = mstrRestApiClass()
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
			controller.RESTUser = self.RESTUser
		}
	}
	
}
