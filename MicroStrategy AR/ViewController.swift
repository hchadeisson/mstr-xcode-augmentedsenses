//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController
{
	
	@IBOutlet weak var sceneView: ARSCNView!
	@IBOutlet weak var currentBalance: UILabel!
	@IBOutlet weak var item: UILabel!
	@IBOutlet weak var itemPrice: UILabel!
	@IBOutlet weak var balanceAfterPurchase: UILabel!
	@IBOutlet weak var balanceAfterPurchaseWithCredit: UILabel!
	@IBOutlet weak var creditDurationLabel: UILabel!
	@IBOutlet weak var creditCostLabel: UILabel!
	@IBOutlet weak var creditMonthlyPaymentLabel: UILabel!
	@IBOutlet weak var creditAnnualRateLabel: UILabel!
	@IBOutlet weak var emptyCart: UIButton!
	@IBOutlet weak var openMyCart: UIButton!
	
	var labelsEditor: labelsEditorClass!
	var simulator = creditSimulatorClass ()
	var cart = cartClass()
	var RESTUser = mstrRestApiClass()
	
	var itemName: String = ""

	@IBAction func creditDurationSlider(_ sender: UISlider)
	{
		updateCreditSimulation(senderValue: Int(sender.value))
	}

	
	let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 0.5
	
	lazy var fadeAndSpinAction: SCNAction =
	{
		return .sequence([
			.fadeIn(duration: fadeDuration),
			.rotateBy(x: 0, y: 0, z: CGFloat.pi * 360 / 180, duration: rotateDuration),
			.wait(duration: waitDuration),.fadeOut(duration: fadeDuration)])
	} ()
	
	lazy var fadeAction: SCNAction =
	{
		return .sequence([
			.fadeOpacity(by: 0.8, duration: fadeDuration),
			.wait(duration: waitDuration),
			.fadeOut(duration: fadeDuration)])
    } ()

    override func viewDidLoad()
	{
		super.viewDidLoad()
		sceneView.delegate = self
		self.simulator.initialize(creditDuration: 12,
								  creditAnnualRate: 0.0,
								  creditMonthlyPayment: 0.0,
								  creditCost: 0.0,
								  balance: 500,
								  price: 0)
		configureLighting()
		
		var login_wait = 0
		while(login_wait < 5)
		{
			login_wait += 1
			if(self.RESTUser.authToken == "")
			{
				print("Waiting for login #\(login_wait)")
				sleep(1)
			}
		}
		
    }
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		resetTrackingConfiguration()
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
		if(self.RESTUser.authToken == "")
		{
			self.performSegue(withIdentifier: "toLandingScreen", sender: self)
		}
		else
		{
			self.cart.getCurrentBasket(RESTUser: &self.RESTUser)
			UserDefaults.standard.set(self.RESTUser.userName, forKey: "userLogin")
			UserDefaults.standard.set(self.RESTUser.getPassword(), forKey: "userPassword")
		}
	}
	
    override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		sceneView.session.pause()
	}
    
    func configureLighting()
	{
		sceneView.autoenablesDefaultLighting = true
		sceneView.automaticallyUpdatesLighting = true
	}
    
	@IBAction func resetButtonTouched(_ sender: Any)
	{
		resetTrackingConfiguration()
		resetLoansConfiguration()
	}

	@IBAction func emptyCartButtonDidTouch(_ sender: UIBarButtonItem)
	{
		self.cart.emptyCart(RESTUser: &self.RESTUser)
		let alertController = UIAlertController(title: "Confirmation", message: "Your cart is now empty", preferredStyle: UIAlertControllerStyle.alert)
		alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alertController, animated: true, completion: nil)

		resetTrackingConfiguration()
		resetLoansConfiguration()
	}
	@IBAction func addToCartDidTouch(_ sender: Any)
	{
		if self.cart.itemName == ""
		{
			let alertController = UIAlertController(title: "No item scanned", message: "Please scan an item or before hitting the Add button", preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
		else
		{
			self.cart.addToCart(simulator: &self.simulator, RESTUser: &self.RESTUser)
			let alertController = UIAlertController(title: "\(self.cart.itemName) added to cart", message: "Please scan more items or open the cart", preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
			self.cart.getCurrentBasket(RESTUser: &self.RESTUser)
		}
	}
	
	@IBAction func openMyCartDidTouch()
	{
		UIApplication.shared.open(URL(string: "dossier://?url=https://tutorial.microstrategy.com/MicroStrategyLibrary/app/00DA0E434629817E141757A44F6FF5CE/3ABF647611E862B6D2F40080EF854718")!)
	}

	@IBAction func openSmartBotDidTouch()
	{
		UIApplication.shared.open(URL(string: "https://webchat.innaas.com/MSTR_HCHADEISSON-AugmentedSenses/chat")!)
	}
	@IBAction func searchButtonDidTouch(_ sender: UIBarButtonItem)
	{
		if self.cart.itemName == ""
		{
			let alertController = UIAlertController(title: "No item scanned", message: "Please scan an item or before hitting the Add button", preferredStyle: UIAlertControllerStyle.alert)
			alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
		}
		else
		{
			runSearch()
		}
    }
	
	func updateCreditSimulation(senderValue: Int)
	{
		self.simulator.updateCreditSimulation(senderValue: senderValue)
		self.creditDurationLabel.text = "\(self.simulator.creditDuration)"
		self.creditAnnualRateLabel.text = "\(self.simulator.creditAnnualRate) %"
		self.creditMonthlyPaymentLabel.text = "\(self.simulator.creditMonthlyPayment) €"
		self.creditCostLabel.text = "\(self.simulator.creditCost) €"
		self.balanceAfterPurchaseWithCredit.text = "\(Double(self.simulator.balance)-self.simulator.creditMonthlyPayment) €"
	}
	
    func resetTrackingConfiguration()
	{
		guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
		let configuration = ARWorldTrackingConfiguration()
		configuration.detectionImages = referenceImages
		let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
		sceneView.session.run(configuration, options: options)
    }
	
	func resetLoansConfiguration()
	{
		self.simulator.price = 0
		self.item.text = ""
		self.cart.setItemName(itemName: "")
		self.itemPrice.text = "0€"
		self.itemPrice.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.0)
		self.creditDurationLabel.text = "-"
		self.creditAnnualRateLabel.text = "Rate: - %"
		self.creditMonthlyPaymentLabel.text = "- €"
		self.creditCostLabel.text = "- €"
		self.balanceAfterPurchase.text = "\(self.simulator.balance) €"
		self.balanceAfterPurchaseWithCredit.text = "\(self.simulator.balance) €"
		self.balanceAfterPurchase.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.0)
	}
	

    func runSearch ()
	{
		var link = ""

		if(self.cart.itemName == "") {link = "https://www.microstrategy.com"}
		else {link = "https://www.google.com/search?btnI=1&q=\(self.cart.itemName.replacingOccurrences(of: " ", with: "%20"))"}

		UIApplication.shared.open(URL(string: link)!)
    }
    
}

extension ViewController: ARSCNViewDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
	{
		guard let imageAnchor = anchor as? ARImageAnchor else { return }
		let referenceImage = imageAnchor.referenceImage
		let imageName = referenceImage.name ?? "no name"
        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
		plane.cornerRadius = 10
		let planeNode = SCNNode(geometry: plane)
		planeNode.opacity = 0.1
		planeNode.eulerAngles.x = -.pi / 2
		// planeNode.runAction(imageHighlightAction)
        node.addChildNode(planeNode)
		DispatchQueue.main.async
		{
			let endIndex = imageName.index(imageName.endIndex, offsetBy: -1)
			self.cart.setItemName(itemName: imageName.substring(to: endIndex).replacingOccurrences(of: "_", with: " "))
			self.simulator.price = self.cart.getItemPrice()
			self.updateCreditSimulation(senderValue: self.simulator.creditDuration)
			self.item.text = "\(self.cart.itemName)"
			self.itemPrice.text = "\(self.simulator.price)€"
			self.itemPrice.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.3)
			self.balanceAfterPurchase.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:0.3)
			self.balanceAfterPurchase.text = "\(self.simulator.balance-self.simulator.price)"
			self.resetTrackingConfiguration()
        }
    }
}
