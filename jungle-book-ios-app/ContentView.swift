//
//  ContentView.swift
//  jungle-book-ios-app
//
//  Created by Schablinger Mathias on 15.02.24.
//
//

import SwiftUI
import CoreData
import MapKit

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        
//        HStack {
//            NavigationLink(destination: AccountView()) {
//                Image(systemName: "person.crop.circle")
//            }
//        }
        TabView {
            PhotoView().tabItem {
                Image(systemName: "camera")
                Text("Photos")
            }
            ExplorerView(viewModel: viewModel).tabItem {
                Image(systemName: "map.fill")
                Text("Explorer")
            }
            PhotobookView(viewModel: viewModel).tabItem {
                Image(systemName: "book.closed.fill")
                Text("Photobook")
            }
        }.task {
            let journals = await loadAllJournals()
            viewModel.journalsLoaded(journals)
            
            let checkpoints = await loadAllCheckpoints()
            viewModel.checkpointsLoaded(checkpoints)
        }
    }
}
public struct PhotoView: View {
    /* @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var image: UIImage?
    public var body: some View {
        VStack {
            Text("Take a photo").font(.system(size: 25));

            if let selectedImage{
                Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
            } else {
                Image(systemName: "camera").font(.system(size: 200))
            }
            
            Button("Take picture") {
                self.showCamera.toggle()
            }.buttonStyle(.bordered)
        }
    } */
    @StateObject var viewModel = ViewModel()
     @State private var isShowingImagePicker = false
        @State private var inputImage: UIImage?

        var body: some View {
            VStack {
                Button("Take Photo") {
                    self.isShowingImagePicker = true
                }
                if let inputImage = self.inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit()
                }
            }
            .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }

        func loadImage() {
            guard let inputImage = inputImage else { return }
            viewModel.uploadImage(inputImage)
        }
}
public struct ExplorerView: View {
    @ObservedObject var viewModel: ViewModel;
    
    public var body: some View {
        VStack {
            Text("Find checkpoints").font(.system(size: 25));
            List(viewModel.checkpoints) {
                checkpoint in
                VStack {
                    Text("Name: \(checkpoint.name)")
                    Text("Coordinates: \(checkpoint.longitude) \(checkpoint.latitude)")
                    Text("Comment: \(checkpoint.comment)")
                    Text("Note: \(checkpoint.note)")
                }
            }
            //Image(systemName: "map.fill").font(.system(size: 200))
        }
    }
}
struct PhotobookView: View {
    @ObservedObject var viewModel: ViewModel;

    var body: some View {
        VStack {
            List(viewModel.journals) {
                journal in
              //  Text("\(journal.name)");
               // JournalView(name: journal.name, image: journal.image)
                
                HStack {
                    Image(systemName: "bookmark.fill").font(.system(size: 25))
                    Spacer()
                    VStack {
                        Text("\(journal.name)").font(.system(.title));
                        AsyncImage(url: URL(string: journal.image)).font(.system(size: 50))
                    }
                    Spacer()
                }
            }
        }
        
    }
    
}
struct JournalView: View {
    var name: String
    var image: String
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark.fill").font(.system(size: 25))
            Spacer()
            VStack {
                Text(name).font(.system(.title));
                Image(systemName: image).font(.system(size: 50))
            }
            Spacer()
        }
    }
}
struct CheckpointView: View {
    var name: String
    var longitude: String
    var latitude: String
    var comment: String
    var note: String
    
    var body: some View {
        VStack {
            Text("Name: \(name)")
            Text("Coordinates: \(longitude) \(latitude)")
            Text("Comment: \(comment)")
            Text("Note: \(note)")
        }
    }
}
//public struct AccountView: View {
//    public var body: some View {
//        VStack {
//            Image(systemName: "person.crop.circle").font(.system(size:35))
//            Text("Johne Doe").font(.system(size:20))
//            TabView {
//                PhotobookView().tabItem {
//                    Image(systemName: "book.closed.fill")
//                    Text("Journals")
//                }
//                CommentView().tabItem {
//                    Image(systemName: "bubble.left.fill")
//                    Text("Comments")
//                }
//            }
//        }
//    }
//}
//struct CommentView: View {
//    public var body: some View {
//        VStack {
//
//        }
//    }
//}
struct ContentView_Previews: PreviewProvider {
    
    static var model: Model = Model();
    static let viewModel: ViewModel = ViewModel(model: model);
    
    
    static var previews: some View {
        ContentView(viewModel: viewModel)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

class ViewModel: ObservableObject {
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        let base64Image = imageData.base64EncodedString()

        // Your backend URL string
        let urlString = "http://localhost:8000/api/upload_image"

        guard let url = URL(string: urlString) else {
            print("Could not create URL from: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = ["image": base64Image]

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