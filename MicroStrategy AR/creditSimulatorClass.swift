//
//  CreditSimulator.swift
//  ARKitImageRecognition
//
//  Created by Chadeisson, Henri-Francois on 5/24/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import Foundation

class creditSimulatorClass
{
    var creditDuration = 12
    var creditAnnualRate = 0.0
    var creditMonthlyPayment = 0.0
    var creditCost = 0.0
    var balance = 500
    var price = 0

	func initialize(creditDuration: Int,
					creditAnnualRate: Float,
					creditMonthlyPayment: Float,
					creditCost: Float,
					balance: Int,
					price: Int)
	{
		self.creditDuration = 12
		self.creditAnnualRate = 0.0
		self.creditMonthlyPayment = 0.0
		self.creditCost = 0.0
		self.balance = 500
		self.price = 0
	}

	func updateCreditSimulation(senderValue: Int)
	{
		self.creditDuration = senderValue
		self.creditAnnualRate = Double(creditDuration)*0.07+8+Double(Int((self.creditDuration+3)/12))+Double(Int(self.price/500))
		self.creditMonthlyPayment = (Double(self.price)*creditAnnualRate*0.01/12)/(1-pow(1+creditAnnualRate*0.01/12, Double(-1*creditDuration)))
		self.creditMonthlyPayment = Double(round(creditMonthlyPayment*100)/100)
		self.creditCost = creditMonthlyPayment*Double(creditDuration)-Double(self.price)
		self.creditCost = Double(round(creditCost*100)/100)
	}
	
	
}
