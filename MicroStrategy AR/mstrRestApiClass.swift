//
//  mstrRestApiClass.swift
//  ARKitImageRecognition
//
//  Created by Chadeisson, Henri-Francois on 11/05/2018.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import Foundation

class mstrRestApiClass
{
	var authToken = ""
	var userName = ""
	var baseUrl = ""
	var projectId = ""
	var datasetId = ""
	private var password = ""
	var jsonResponse: [String: Any]!
	
	init ()
	{
		
	}
	
	init (baseUrl: String, projectId: String, userName: String)
	{
		self.setBaseUrl(baseUrl: baseUrl)
		self.setProjectId(projectId: projectId)
		self.setUserName(userName: userName)
	}
	
	func setBaseUrl(baseUrl: String)
	{
		self.baseUrl = baseUrl
	}
	
	func setDatasetId(datasetId: String)
	{
		self.datasetId = datasetId
	}
	
	func setProjectId(projectId: String)
	{
		self.projectId = projectId
	}
	
	func setUserName(userName: String)
	{
		if (userName == "")
		{
			self.userName = "dummy_did_not_fill"
		}
		else
		{
			self.userName = userName
		}
	}
	
	func setPassword(password: String)
	{
		if (password == "")
		{
			self.password = "dummy_did_not_fill"
		}
		else
		{
			self.password = password
		}
	}
	
	func getPassword() -> String
	{
		return self.password
	}
	func Authentication_postAuthLogin(password: String, loginMode: Int)
	{
		let loginPayload = "{\"username\": \"\(self.userName)\",\"password\": \"\(password)\",\"loginMode\": \(loginMode)}"
		let anonymousLoginPayload = "{\"username\": \"\(self.userName)\",\"password\": \"**********\",\"loginMode\": \(loginMode)}"
		self.authToken = ""
		print(anonymousLoginPayload)

		let request = NSMutableURLRequest(url: NSURL(string: "\(self.baseUrl)/auth/login")! as URL)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.httpMethod = "POST"
		request.httpBody = loginPayload.data(using: .utf8)
		
		var mstrApiResponse = HTTPURLResponse()
		
		let task = URLSession.shared.dataTask(with: request as URLRequest)
		{
			data, response, error in
			guard let _ = data, error == nil else // check for fundamental networking error
			{
				print("error=\(String(describing: error))")
				return
			}
	
			let defaults = UserDefaults.standard
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 204 // check for http errors
			{
				print("statusCode should be 204, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
				defaults.set("", forKey: "userLogin")
				defaults.set("", forKey: "userPassword")

			}
			else
			{
				mstrApiResponse = response! as! HTTPURLResponse
				self.authToken = mstrApiResponse.allHeaderFields["x-mstr-authtoken"] as! String
				print("Token: \(self.authToken)")
				defaults.set(self.userName, forKey: "userName")
				defaults.set(self.password, forKey: "password")
			}
			return
		}
		
		task.resume()
	}
	
	func Projects_getProjects()
	{
		let headers =
		[
			"Accept": "application/json",
			"X-MSTR-AuthToken": "\(self.authToken)",
			"Cache-Control": "no-cache"
		]
		
		let request = NSMutableURLRequest(url: NSURL(string: "\(self.baseUrl)/projects")! as URL,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.allHTTPHeaderFields = headers
		request.httpMethod = "GET"

		let session = URLSession.shared
		let dataTask = session.dataTask(with: request as URLRequest,
										completionHandler:
			{
				(data, response, error) -> Void in
				if (error != nil)
				{
					print(error!)
				}
				else
				{
					_ = response as? HTTPURLResponse // var httpresponse
				}
			})
		dataTask.resume()
	}

	func Cube_postCreateCubeInstance(payload: String, projectId: String, datasetId: String, callback: @escaping (_ result: [String : Any]?) -> Void)
	{
		let request = NSMutableURLRequest(url: NSURL(string: "\(self.baseUrl)/cubes/\(datasetId)/instances?limit=1000")! as URL)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("\(self.authToken)", forHTTPHeaderField: "X-MSTR-AuthToken")
		request.addValue("\(projectId)", forHTTPHeaderField: "X-MSTR-ProjectID")
		request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
		request.httpMethod = "POST"
		request.httpBody = payload.data(using: .utf8)
		
		print("Cube Token: \(self.authToken)")
		print("Cube Payload: \(payload)")
		self.jsonResponse = ["empty": "empty"]
		let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
			guard let _ = data, error == nil else // check for fundamental networking error
			{
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 // check for http errors
			{
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
//				print("response = \(String(describing: response))")
			}
			
			_ = response! as! HTTPURLResponse
			let json = try? JSONSerialization.jsonObject(with: data!, options: [])
			self.jsonResponse = json as? [String: Any]
			return
		}
		
		callback(self.jsonResponse)
		
		task.resume()
	}

	func Dataset_postCreateDICube(payload: String, projectId: String, datasetId: String, tableName: String, updatePolicy: String)
	{
		let request = NSMutableURLRequest(url: NSURL(string: "\(self.baseUrl)/datasets")! as URL,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("\(self.authToken)", forHTTPHeaderField: "X-MSTR-AuthToken")
		request.addValue("\(projectId)", forHTTPHeaderField: "X-MSTR-ProjectID")
		request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
		request.httpMethod = "POST"
		request.httpBody = payload.data(using: .utf8)
		
		let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
			guard let _ = data, error == nil else // check for fundamental networking error
			{
				print("error=\(String(describing: error))")
				return
			}
			
			if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 // check for http errors
			{
				print("statusCode should be 200, but is \(httpStatus.statusCode)")
				print("response = \(String(describing: response))")
			}
			
			_ = response! as! HTTPURLResponse
			print(data!)
			return
		}
		
		task.resume()
	}
	
	func Dataset_patchUpdateDICube(payload: String, projectId: String, datasetId: String, tableName: String, updatePolicy: String)
	{
		print(payload)
		let headers =
		[
			"Content-Type": "application/json",
			"Accept": "application/json",
			"X-MSTR-AuthToken": "\(self.authToken)",
			"X-MSTR-ProjectID": "\(projectId)",
			"Cache-Control": "no-cache",
			"updatePolicy": "\(updatePolicy)"
		]
		
		let request = NSMutableURLRequest(url: NSURL(string: "\(self.baseUrl)/datasets/\(datasetId)/tables/\(tableName)")! as URL,
										  cachePolicy: .useProtocolCachePolicy,
										  timeoutInterval: 10.0)
		request.httpMethod = "PATCH"
		request.httpBody = payload.data(using: .utf8)
		request.allHTTPHeaderFields = headers
		
		print(payload)
		
		let session = URLSession.shared
		let dataTask = session.dataTask(with: request as URLRequest, completionHandler:
		{
			(data, response, error) -> Void in
			if (error != nil)
			{
				print(error!)
			}
			else
			{
				_ = response as? HTTPURLResponse
				print(String(data: data!, encoding: String.Encoding.utf8)!)
			}
		})
		dataTask.resume()
	}
	
}
