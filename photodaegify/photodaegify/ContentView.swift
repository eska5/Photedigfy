import SwiftUI
import UIKit
import Foundation
import Vision
import AVKit

struct ContentView: View {
    
    @State private var placeholder = 0
    @State private var selectedOption = 1
    @State private var isPresented = false
    @State private var resultImage: UIImage?
    @State private var image1: UIImage?
    @State private var image2: UIImage?
    @State private var isResult = false
    @State private var isImagePickerPresented = false
    @State private var isCameraSource = false
    @State private var semanticImage = SemanticImage()
    @State private var selectedOptionSingle = 0
    @State private var selectedOptionDouble = 0
    @State private var scrollViewOffset: CGFloat = 0
    
    let optionsSingle = ["Znajdź osobę","Znajdź obiekt","zaszumienie tła", "Odszumanie"]
    let optionsDouble = ["przeklejenie pierwszego planu(obiekt)", "przeklejenie pierwszego planu(osoba)" ]
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor(rgb: 0x242429)))
                    .ignoresSafeArea()
                if isPresented == true {
                    FullScreenImageView(resultImage: $resultImage, isResult: $isPresented)
                    .zIndex(1)
                }
                VStack {
                    Picker("Liczba zdjęć", selection: $selectedOption) {
                        Text("1 zdjęcie").tag(1)
                        Text("2 zdjęcia").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color(UIColor(rgb: 0x2E3B59)))
                    .tint(Color(UIColor(rgb: 0x2E3B59)))
                    .padding()
                    
                    if selectedOption == 1 {
                        ImageSelector(uiImage: $image1)
                    } else if selectedOption == 2 {
                        HStack {
                            ImageSelector(uiImage: $image1)
                            ImageSelector(uiImage: $image2)
                        }
                    }
                                
                    HStack {
                        Button(action: {
                            isCameraSource = true
                            isImagePickerPresented.toggle()
                        }) {
                            Text("Zrób Zdjęcie")
                        }
                        .buttonStyle(CustomButtonStyle())
                        
                        Button(action: {
                            isCameraSource = false
                            isImagePickerPresented.toggle()
                        }) {
                            Text("Wybierz Zdjęcie")
                        }
                        .buttonStyle(CustomButtonStyle())
                    }
                                        
                    VStack {
                        Text("Wybór operacji")
                            .font(.headline)
                            .padding(.vertical, 15)

                        if selectedOption == 1 {
                            GeometryReader { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(0..<optionsSingle.count, id: \.self) { index in
                                            Text(optionsSingle[index])
                                                .padding(10)
                                                .background(selectedOptionSingle == index ? Color(UIColor(rgb: 0xF4704B)) : Color(UIColor(rgb: 0x748EA5)))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    selectedOptionSingle = index
                                                }
                                        }
                                    }
                                }
                            }
                                                        
                            Text("")
                                .font(.headline)
                                .padding(.top, 15)

                        } else if selectedOption == 2
                        {
                            GeometryReader { geometry in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(0..<optionsDouble.count, id: \.self) { index in
                                            Text(optionsDouble[index])
                                                .padding(10)
                                                .background(selectedOptionDouble == index ? Color(UIColor(rgb: 0xF4704B)) : Color(UIColor(rgb: 0x748EA5)))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .onTapGesture {
                                                    selectedOptionDouble = index
                                                }
                                        }
                                    }
                                }
                            }
                            Text("")
                                .font(.headline)
                                .padding(.top, 15)
                        }
                    }
                    .padding(.horizontal, 15)
                    HStack {
                        Button(action: {
                            print(selectedOption)
                            print(selectedOptionDouble)
                            if selectedOption == 1 && selectedOptionSingle == 0 {
                                resultImage = semanticImage.personMaskImage(uiImage: image1!)
                            } else if selectedOption == 1 && selectedOptionSingle == 1 {
                                resultImage = semanticImage.saliencyMask(uiImage: image1!);
                            } else if selectedOption == 1 && selectedOptionSingle == 2 {
                                resultImage = semanticImage.personBlur(uiImage:image1!, intensity:50.0);
                            } else if selectedOption == 1 && selectedOptionSingle == 3 {
                                resultImage = denoiseImage(image:image1!, blurRadius: 5.0)
                            } else if selectedOption == 2 && selectedOptionDouble == 0 {
                                resultImage = semanticImage.saliencyBlend(objectUIImage: image1!, backgroundUIImage: image2!);
                            } else if selectedOption == 2 && selectedOptionDouble == 1 {
                                resultImage = semanticImage.swapBackgroundOfPerson(personUIImage: image1!, backgroundUIImage: image2!)
                            }
                            isResult = true
                        }) {
                            Text("Włącz")
                        }
                        .foregroundColor(Color(UIColor(rgb: 0xD6D681)))
                        .buttonStyle(CustomButtonStyle())
                        
                        
                        if resultImage != nil {
                            Button(action: {
                                    isPresented = true
                                }) {
                                    Text("Podgląd")
                                }
                                .buttonStyle(CustomButtonStyle())
                            Image(uiImage: resultImage!)
                                .resizable()
                                .frame(width: 160, height: 160)
                        }
                    }
                    .padding(.top, 20)
                    
                    
                    HStack {
                        ZStack(alignment: .bottomLeading) {
                            Button(action: {
                                isResult = false
                                resultImage = nil
                                image1 = nil
                                image2 = nil
                            }) {
                                Text("Reset")
                            }
                            .position(x:75, y:UIScreen.main.bounds.height - 780)
                            .buttonStyle(CustomButtonStyle())
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Photodaegify")
                            .font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader)
                            .foregroundColor(Color(UIColor(rgb: 0xF4704B)))
                            .padding(.top, 30)
                    }
                }
                .padding(.top, 50)
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePickerView(image1: selectedOption == 1 ? $image1 : $image2, isCameraSource: isCameraSource)
                }
            }
        }
    }
    
    struct ImageSelector: View {
        @Binding var uiImage: UIImage?
        
        var body: some View {
            VStack {
                Button(action: {

                }) {
                    if let image = uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 160, height: 160)
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 160, height: 160)
                            .foregroundColor(Color(UIColor(rgb: 0xE5E9E1)))
                    }
                }
            }
        }
    }
}

struct ScrollViewProxyKey: PreferenceKey {
    static var defaultValue: ScrollViewProxyValue?
    
    static func reduce(value: inout ScrollViewProxyValue?, nextValue: () -> ScrollViewProxyValue?) {
        value = nextValue()
    }
}

struct ScrollViewProxyValue {
    var scrollGeometry: GeometryProxy?
}


struct ImagePickerView: View {
    @Binding var image1: UIImage?
    var isCameraSource: Bool
    
    var body: some View {
        VStack {
            if isCameraSource {
                CameraView(image: $image1)
            } else {
                PhotoLibraryView(image: $image1)
            }
        }
    }
}

struct CameraView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        ImagePicker(isCameraSource: true, uiImage: $image)
    }
}

struct PhotoLibraryView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        ImagePicker(isCameraSource: false, uiImage: $image)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var isCameraSource: Bool
    @Binding var uiImage: UIImage?
    
    init(isCameraSource: Bool, uiImage: Binding<UIImage?>) {
        self.isCameraSource = isCameraSource
        self._uiImage = uiImage
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.allowsEditing = true
        imagePicker.sourceType = isCameraSource ? .camera : .photoLibrary
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.uiImage = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color(UIColor(rgb: 0xF4704B)) : Color(UIColor(rgb: 0x2E3B59)))
            .foregroundColor(Color(UIColor(rgb: 0xE5E9E1)))
            .cornerRadius(20)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

public func convert(image: Image, callback: @escaping ((UIImage?) -> Void)) {
    DispatchQueue.main.async {
        let renderer = ImageRenderer(content: image)
        callback(renderer.uiImage)
    }
}


public func denoiseImage(image: UIImage, blurRadius: CGFloat) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    
    let inputImage = CIImage(cgImage: cgImage)
    
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter?.setValue(blurRadius, forKey: kCIInputRadiusKey)
    
    if let outputImage = filter?.outputImage {
        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
    }
    
    return nil
}
