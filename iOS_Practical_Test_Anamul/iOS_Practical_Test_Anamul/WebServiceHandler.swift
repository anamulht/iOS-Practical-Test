//
//  WebServiceHandler.swift
//  iOS_Practical_Test_Anamul
//
//  Created by Anamul Habib on 10/30/21.
//

import Foundation
import SystemConfiguration
import UIKit

class WebServiceHandler{
    
    private static var instance : WebServiceHandler!
    static let shared : WebServiceHandler = {
        
        if instance == nil{
            instance = WebServiceHandler()
        }
        
        return instance
    }()
    
    private init(){}
        
    lazy var baseUrl = "https://api.themoviedb.org/3/"
    
    enum RequestMethod: String{
        case get = "GET"
        case post = "POST"
    }
    
    //https://api.themoviedb.org/3/search/movie?api_key=38e61227f85671163c275f9bd95a8803&query=marvel  
    private func makeRequest(endPoint: String, method: RequestMethod, parameters: [String: Any?]?, onCompletion: @escaping (Data) -> Void, onFailure: @escaping (Error?) -> Void, shouldShowLoader: Bool, onConnectionFailure: (() -> ())? = nil){
        
        if isConnectedToNetwork(){
            
            let apiUrl = baseUrl + endPoint
            guard var urlComponent = URLComponents(string: apiUrl) else{
                onFailure(nil)
                return
            }
            
            if let parameters = parameters, method == .get{
                let queryItems = parameters.map  { URLQueryItem(name: $0.key, value: $0.value as? String) }
                urlComponent.queryItems = queryItems
            }
            
            guard let url = urlComponent.url else{
                onFailure(nil)
                return
            }

            var urlRequest = URLRequest(url: url)
            
            if let parameters = parameters, method == .post{
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
                    urlRequest.httpBody = jsonData
                }catch{
                    onFailure(error)
                }
            }
            
            urlRequest.httpMethod = method.rawValue
            
            let session = URLSession.shared
            
            if shouldShowLoader{
                DispatchQueue.main.async {
                    Loader.shared.startAnimation()
                }
            }
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            session.dataTask(with: urlRequest) { (data, response, error) in
                
                if shouldShowLoader{
                    DispatchQueue.main.async {
                        Loader.shared.stopAnimation()
                    }
                }
                
                guard (response as? HTTPURLResponse)?.statusCode != 401 else{
                    DispatchQueue.main.async {
                        self.handleNotAunthenticated()
                        Loader.shared.stopAnimation()
                    }
                    return
                }
                
                guard error == nil else{
                    onFailure(error)
                    return
                }
                
                guard let data = data else{
                    onFailure(nil)
                    return
                }
                
                print("\n\(apiUrl) with parameters: \(parameters) response: \(String.init(data: data, encoding: .utf8)!)\n")
                onCompletion(data)
                
            }.resume()
            
        }else{
            if let onConnectionFailure = onConnectionFailure{
                onConnectionFailure()
            }else{
                handleNoNetwork()
            }
        }
    }
    
    func fetchMovie(query: String?, onSuccess: @escaping (_ response: SearchedMovieInfoResponseModel) -> Void, onFailure: @escaping (Error?) -> Void, shouldShowLoader: Bool, onConnectionFailure: (() -> ())? = nil){
        
        makeRequest(endPoint: "search/movie", method: .get, parameters: ["api_key": "38e61227f85671163c275f9bd95a8803", "query": query], onCompletion: { (data) in
            
            do{
                let response = try JSONDecoder().decode(SearchedMovieInfoResponseModel.self, from: data)
                DispatchQueue.main.async {
                    onSuccess(response)
                }
            }catch {
                DispatchQueue.main.async {
                    onFailure(error)
                }
            }
            
        }, onFailure: { (error) in
            onFailure(error)
        }, shouldShowLoader: shouldShowLoader, onConnectionFailure: onConnectionFailure)
    }
    
    
    
    private func handleNoNetwork(){
        
    }
    
    private func handleNotAunthenticated(){
        
    }
    
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                
                SCNetworkReachabilityCreateWithAddress(nil, $0)
                
            }
            
        }) else {
            
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

private let imageCache = NSCache<NSString, UIImage>()
extension UIImageView{
    
    func setImageFromURl(imageUrl: String, cacheEnabled: Bool){
        
        self.image = nil
        if(cacheEnabled){
            if let cachedImage = imageCache.object(forKey: NSString(string: imageUrl)) {
                self.image = cachedImage
                return
            }
        }
        
        if let url = URL(string: imageUrl) {
            self.backgroundColor = .init(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 0.6)
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(error?.localizedDescription ?? "unknown error")")
                    DispatchQueue.main.async {
                        self.backgroundColor = nil
                        self.image = #imageLiteral(resourceName: "noImage")
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            if(cacheEnabled){
                                imageCache.setObject(downloadedImage, forKey: NSString(string: imageUrl))
                            }
                            self.backgroundColor = nil
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
        
    }
}

