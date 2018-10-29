//
//  Cart.swift
//  ARKitImageRecognition
//
//  Created by Chadeisson, Henri-Francois on 5/24/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import Foundation

class cartClass
{
	var jsonCart = ""
	var itemName = ""
	var itemPrice = 0
	var loanDurationAttr = ""
	var itemAttr = ""
	var userNameAttr = ""
	var cartDossierUrl = ""
	var smartBotUrl = ""
	var currentBasket: [String: Any]!
	
	func setItemName (itemName: String)
	{
		self.itemName = itemName
	}
	
	func setEnv(loanDurationAttr: String, itemAttr: String, userNameAttr: String, cartDossierUrl: String, smartBotUrl: String)
	{
		self.loanDurationAttr = loanDurationAttr
		self.itemAttr = itemAttr
		self.userNameAttr = userNameAttr
		self.cartDossierUrl = cartDossierUrl
		self.smartBotUrl = smartBotUrl
	}
	
	func getCurrentBasket(RESTUser: inout mstrRestApiClass)
	{
		let payload = "{\"requestedObjects\":{\"attributes\":[{\"id\":\"\(self.loanDurationAttr)\"},{\"id\":\"\(self.itemAttr)\"}]},\"viewFilter\":{\"operator\":\"In\",\"operands\":[{\"type\":\"attribute\",\"id\":\"\(self.userNameAttr)\"},{\"type\":\"elements\",\"elements\":[{ \"id\":\"\(self.userNameAttr):\(RESTUser.userName)\"}]}]}}"
		
		RESTUser.Cube_postCreateCubeInstance(payload: payload, projectId: RESTUser.projectId, datasetId: RESTUser.datasetId)
		{
			result in
			guard result != nil else
			{
				return
			}
			self.currentBasket = result
		}
	}

	func addToCart (simulator: inout creditSimulatorClass, RESTUser: inout mstrRestApiClass)
	{
		let jsonCart = self.jsonizeCart(simulator: &simulator, RESTUser: &RESTUser)
		let base64Cart = base64encoder(str: jsonCart)
		let payload = "{ \"name\":\"SCANNED_ITEMS\",\"columnHeaders\": [{\"name\": \"USERNAME\", \"dataType\": \"STRING\"  },  {\"name\": \"ITEM\", \"dataType\": \"STRING\"  },  {  \"name\": \"PRICE\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"RATE\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"DURATION\",  \"dataType\": \"STRING\"  },  {  \"name\": \"COST\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"MONTHLY\",  \"dataType\": \"DOUBLE\"  }  ],  \"data\": \"\(base64Cart)\" }"
		let cartTable = "SCANNED_ITEMS"
		RESTUser.Dataset_patchUpdateDICube(payload: payload, projectId: RESTUser.projectId, datasetId: RESTUser.datasetId, tableName: cartTable, updatePolicy: "Upsert")
	}
	
	func emptyCart (RESTUser: inout mstrRestApiClass)
	{
		let result = RESTUser.jsonResponse!["result"] as! [String: Any]
		let data = result["data"] as! [String: Any]
		let paging = data["paging"] as! [String: Any]
		let total_rows = paging["total"] as! Int
		let root = data["root"] as! [String: Any]
		let children = root["children"] as! [Any]
		var row_index = 0
		
		var jsonData = ""
		for childNode in children // loop through rows
		{
			var child = childNode as! [String: Any]
			var element = child["element"] as! [String: Any]
			var formValues = element["formValues"] as! [String: Any]
			let itemChildNodes = child["children"] as! [Any]
			var duration = 0
			for (key, value) in formValues
			{
				if(key == "ID")
				{
					duration = (value as! NSString).integerValue
				}
			}
			
			for itemChildNode in itemChildNodes
			{
				var itemChild = itemChildNode as! [String: Any]
				element = itemChild["element"] as! [String: Any]
				formValues = element["formValues"] as! [String: Any]
				var item = ""
				for (key, value) in formValues
				{
					if(key == "ID")
					{
						item = value as! String
					}
				}
				row_index += 1
				jsonData += "{\"USERNAME\": \"\(RESTUser.userName)\",\"ITEM\": \"\(item)\",\"PRICE\": 0,\"RATE\": 0,\"DURATION\": \"\(duration)\",\"COST\": 0,\"MONTHLY\": 0}"
				if(row_index < total_rows)
				{
					jsonData += ","
				}
			}
		}
		
		jsonData = "[\(jsonData)]"
		let base64jsonData = base64encoder(str: jsonData)

		let payload = "{ \"name\":\"SCANNED_ITEMS\",\"columnHeaders\": [{\"name\": \"USERNAME\", \"dataType\": \"STRING\"  },  {\"name\": \"ITEM\", \"dataType\": \"STRING\"  },  {  \"name\": \"PRICE\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"RATE\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"DURATION\",  \"dataType\": \"STRING\"  },  {  \"name\": \"COST\",  \"dataType\": \"DOUBLE\"  },  {  \"name\": \"MONTHLY\",  \"dataType\": \"DOUBLE\"  }  ],  \"data\": \"\(base64jsonData)\" }"
		let cartTable = "SCANNED_ITEMS"
		RESTUser.Dataset_patchUpdateDICube(payload: payload, projectId: RESTUser.projectId, datasetId: RESTUser.datasetId, tableName: cartTable, updatePolicy: "Upsert")
	}
	
	func base64encoder (str: String) -> NSString
	{
		let utf8str: NSData = str.data(using: String.Encoding.utf8)! as NSData
		let base64Encoded:NSString = utf8str.base64EncodedString() as NSString
		return base64Encoded
	}
	
	func jsonizeCart (simulator: inout creditSimulatorClass, RESTUser: inout mstrRestApiClass) -> String
	{
		let jsonCart = "[{\"USERNAME\": \"\(RESTUser.userName)\",\"ITEM\": \"\(self.itemName)\",\"PRICE\": \(simulator.price),\"RATE\": \(simulator.creditAnnualRate),\"DURATION\": \"\(simulator.creditDuration)\",\"COST\": \(simulator.creditCost),\"MONTHLY\": \(simulator.creditMonthlyPayment)}]"
		return jsonCart
	}
	
	func getItemPrice () -> Int
	{
		switch(self.itemName)
		{
			case("switch"):
				self.itemPrice = 300
			case("ipad"):
				self.itemPrice = 800
			case("iphone"):
				self.itemPrice = 530
			case("iphonex"):
				self.itemPrice = 1000
			case("pencil"):
				self.itemPrice = 100
			case("macbook pro"):
				self.itemPrice = 2799
			case("ps4"):
				self.itemPrice = 280
			case("amazon echo"):
				self.itemPrice = 110
			case("bottle"):
				self.itemPrice = 1
			default:
				self.itemPrice = 0
		}
		
		return self.itemPrice
	}

}
