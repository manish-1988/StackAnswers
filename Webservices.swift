      //
      //  Webservices.swift
      // HeroEyez
      //
      //  Created by MANISH_iOS on 01/08/16.
      //  Copyright © 2016 iDev Softwares. All rights reserved.
      //
      
      import UIKit
      import Alamofire
      
      class Webservices: NSObject
      {
        static let sharedInstance = Webservices()
        let sharedApp  = UIApplication.shared
        
        override init()
        {
            super.init()
        }
        
        func postImageRequest(_ serviceName : String, parameters : [String : String]!, showLoader : Bool, imageData : Data, imageName : String, imageType : String, completionHandler :@escaping (_ response : AnyObject?, _ status : Bool, _ error : String?, _ time : Timeline?) -> Void)
        {
            guard let url = URL(string: Macros.URLs.baseServer + serviceName) else {
                completionHandler(nil, false, "Error: cannot create URL", nil)
                return
            }
            
            let frame = CGRect(x: Macros.ScreenSize.screenWidth  / 2 - 16, y: 250, width: 100, height: 20)
            let myProgressView = UILabel(frame: frame)
            myProgressView.font = Macros.Fonts.robotoBold
            myProgressView.center = CGPoint(x: (appDelegate.window?.center.x)!, y: myProgressView.center.y)
            
            //        myProgressView.textColor = UIColor.color(0, green: 99, blue: 1, alpha: 1.0)
            myProgressView.textColor = UIColor.white
            myProgressView.textAlignment = .center
            
            myProgressView.layer.zPosition = CGFloat.greatestFiniteMagnitude
            appDelegate .window!.addSubview(myProgressView)

            DispatchQueue.main.async(execute: {
                myProgressView.text = "Begin"
                
            })

            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
     
                    for (key, value) in parameters
                    {
                        if key == "ProfilePhoto"
                        {
                            multipartFormData.append(imageData, withName: key, fileName: "ProfilePhoto", mimeType: "image/png")
                        }else
                        {
                            
                            multipartFormData.append((value.data(using: .utf8))!, withName: key)

                        }
                    }
                },
                to: url,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            
                            Singleton.sharedInstance.delay(3.0, closure: {
                                myProgressView .removeFromSuperview()
                            })

                            if let value = response.result.value
                            {
                                DispatchQueue.main.async(execute: {
                                    
                                    myProgressView.text = "Successfull"
                                })

                                
                                completionHandler(value as AnyObject?, true, nil, response.timeline)
                            }else
                            {
                                DispatchQueue.main.async(execute: {
                                    myProgressView.text = "Failed"
                                })

                                completionHandler(nil, true, "Failed", response.timeline)
                            }

                        }
                        upload.uploadProgress(queue: DispatchQueue(label: "uploadQueueHE"), closure: { (progress) in

                            DispatchQueue.main.async(execute: {
                                DispatchQueue.main.async(execute: {
                                    let formatted = String(format: "%.2f", progress.fractionCompleted * 100)
                                    myProgressView.text = "\(formatted) %"
                                })
                                
                            })


                        })
                        
                    case .failure(let encodingError):
                        print(encodingError)
                    }
                }
            )
            
        }
        

        /*!
         Post request global
         
         - parameter serviceName:       Name of service
         - parameter parameters:        <#parameters description#>
         - parameter showLoader:        <#showLoader description#>
         - parameter completionHandler: <#completionHandler description#>
         */
        func postRequest(_ serviceName : String, parameters : [String : Any]!, showLoader : Bool, completionHandler :@escaping  (_ response : AnyObject?, _ status : Bool, _ error : String?, _ time : Timeline?) -> Void)
        {

            guard let url = URL(string: Macros.URLs.baseServer + serviceName) else {

                completionHandler(nil, false, "Error: cannot create URL", nil)
                return
            }

            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: [:]).responseJSON
                { (response) in
                    
                    //http://web1-testserver.cloudapp.net:91/api/Account/Login
                    guard response.result.error == nil else
                    {
                        completionHandler(nil, false, (response.result.error?.localizedDescription)!, response.timeline)
                        return
                    }
                    if let value = response.result.value
                    {
                        completionHandler(value as AnyObject?, true, nil, response.timeline)
                        
                    }else
                    {
                        completionHandler(nil, false, (response.result.error?.localizedDescription)!, response.timeline)
                    }
                    
            }
        }
        
        func getRequest(_ serviceName : String, parameters : [String : Any]!,  showLoader : Bool, completionHandler :@escaping  (_ response : AnyObject?, _ status : Bool, _ error : String?, _ time : Timeline?) -> Void)
        {
            

            
            guard let url = URL(string: Macros.URLs.baseServer + serviceName) else {
       
                
                completionHandler(nil, false, "Error: cannot create URL", nil)
                return
            }
            
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default)
                .downloadProgress { progress in
                    print("Progress: \(progress.fractionCompleted)")
                }
                .validate { request, response, data in
                    // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                    return .success
                }
                .responseJSON { response in
                    debugPrint(response)
                    
        
                    
                    
                    guard response.result.error == nil else
                    {
                        ////customLogger.info(response.result.error?.localizedDescription)
                        // got an error in getting the data, need to handle it
                        completionHandler(nil, false,  (response.result.error?.localizedDescription)!,  response.timeline)
                        return
                    }
                    
                    if let value = response.result.value
                    {
                        completionHandler(value as AnyObject?, true, nil, response.timeline)
                        
                    }else
                    {
                        completionHandler(nil, false, (response.result.error?.localizedDescription)!, response.timeline)
                    }
                    
            }
        }
      }
      
      /***** Usage ******/
      
      /*
       
       let parameters =
       [
       "Username": usernameTF.text!,
       "Password": passwordTF.text!,
       "UserDevice": [
       "DeviceRegistrationId": Macros.Constants.deviceRegistrationID,
       "DeviceId": NSNull(),
       "DeviceZone": "APNS",
       "IsPushNotify": true
       ]
       ] as [String : Any]
       
       print(Macros.Constants.deviceRegistrationID)
       print(parameters)
       
       Webservices.sharedInstance.postRequest(Macros.ServiceName.login, parameters: parameters as [String : AnyObject], showLoader: true) { (response, status, error, time) in
       
       print("Time taken for \(Macros.ServiceName.login) api - is \(time)")
       if error == nil && status == true
       {
       }
    }

       
       */
      
      
      
