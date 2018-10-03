//
//  labelsEditorClass.swift
//  ARKitImageRecognition
//
//  Created by Chadeisson, Henri-Francois on 5/27/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import Foundation

class labelsEditorClass
{

	func resetValues(viewControler: ViewController, simulator: creditSimulatorClass)
	{
		viewControler.item.text = ""
		viewControler.itemPrice.text = "0€"
		viewControler.itemPrice.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.0)
		viewControler.creditDurationLabel.text = "-"
		viewControler.creditAnnualRateLabel.text = "Rate: - %"
		viewControler.creditMonthlyPaymentLabel.text = "- €"
		viewControler.creditCostLabel.text = "- €"
		viewControler.balanceAfterPurchase.text = "\(simulator.balance) €"
		viewControler.balanceAfterPurchaseWithCredit.text = "\(simulator.balance) €"
		viewControler.balanceAfterPurchase.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.0)
	}
	
	func updateCreditSimulation(viewControler: ViewController, simulator: creditSimulatorClass)
	{
		viewControler.creditDurationLabel.text = "\(simulator.creditDuration)"
		viewControler.creditAnnualRateLabel.text = "\(simulator.creditAnnualRate) %"
		viewControler.creditMonthlyPaymentLabel.text = "\(simulator.creditMonthlyPayment) €"
		viewControler.creditCostLabel.text = "\(simulator.creditCost) €"
		viewControler.balanceAfterPurchaseWithCredit.text = "\(Double(simulator.balance)-simulator.creditMonthlyPayment) €"
	}
	
	func updateScannedItem(viewControler: ViewController, simulator: creditSimulatorClass, cart: cartClass)
	{
		viewControler.item.text = "\(cart.itemName)"
		viewControler.itemPrice.text = "\(simulator.price)€"
		viewControler.itemPrice.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.3)
		viewControler.balanceAfterPurchase.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.3)
		viewControler.balanceAfterPurchase.text = "\(simulator.balance-simulator.price)"
	}
}
