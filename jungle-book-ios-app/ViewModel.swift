//
//  ViewModel.swift
//  jungle-book-ios-app
//
//  Created by Schablinger Mathias on 13.03.24.
//

import Foundation
import SwiftUI
class ViewModel: ObservableObject {
    @Published private(set) var model = Model()
    
    init(model: Model){
        self.model = model;
    }
    
    var journals: [Journal] {
        model.journals
    }
    var checkpoints: [Checkpoint] {
        model.checkpoints
    }
    func setJournals(journals: [Journal]) {
        model.setJournals(journals)
    }
    func journalsLoaded(_ journals: [Journal]) {
        model.setJournals(journals)
    }
    func checkpointsLoaded(_ checkpoints: [Checkpoint]) {
        model.setCheckpoints(checkpoints)
    }
    func setCheckpoints(checkpoints: [Checkpoint]) {
        model.setCheckpoints(checkpoints)
    }
    func uploadImage(paramName: String, fileName: String, image: UIImage) {
        let url = URL(string: "http://172.17.28.48:8000/api/journal/upload-image")
    
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
    
        let session = URLSession.shared
    
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
    
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
        var data = Data()
    
    // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpgData()!)
    
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            }
        }).resume()
    }
}
