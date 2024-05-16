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
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        let base64Image = imageData.base64EncodedString()

        let urlString = "http://172.17.28.48:8000/api/journal/upload_image"
        
        guard let url = URL(string: urlString) else {
            print("Could not create URL from: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = ["imageName": base64Image]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
}
