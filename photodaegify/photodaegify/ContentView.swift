import SwiftUI

struct ContentView: View {
    @State private var selectedOption = 1
    @State private var resultImage: Image?
    @State private var image1: Image?
    @State private var image2: Image?
    @State private var isResult = false
    @State private var isImagePickerPresented = false
    @State private var isCameraSource = false
    // Carousel
    @State private var selectedOptionSingle = 0 // Track the selected option index
    @State private var selectedOptionDouble = 0 // Track the selected option index
    @State private var scrollViewOffset: CGFloat = 0
    
    let optionsSingle = ["Odszumanie", "zaszumienie tła", "usuwanie pierwszego planu"]
    let optionsDouble = ["modyfikacja kolorów", "przeklejenie pierwszego planu"]
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Rectangle() // Add a Rectangle as a background with the desired color
                    .fill(Color(UIColor(rgb: 0x242429))) // Set the background color
                    .ignoresSafeArea()
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
                        ImageSelector(image: $image1)
                    } else if selectedOption == 2 {
                        HStack {
                            ImageSelector(image: $image1)
                            ImageSelector(image: $image2)
                        }
                    }
                                        
                    HStack {
                        Button(action: {
                            isCameraSource = true
                            isImagePickerPresented.toggle()
                        }) {
                            Text("Zrób Zdjęcie")
                        }
                        .buttonStyle(CustomButtonStyle()) // Apply custom button style
                        
                        Button(action: {
                            isCameraSource = false
                            isImagePickerPresented.toggle()
                        }) {
                            Text("Wybierz Zdjęcie")
                        }
                        .buttonStyle(CustomButtonStyle()) // Apply custom button style
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
                                                        
                            Text("\(optionsSingle[selectedOptionSingle])")
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
                            Text("\(optionsDouble[selectedOptionDouble])")
                                .font(.headline)
                                .padding(.top, 15)
                        }
                    }
                    .padding(.horizontal, 15)
                       
                    HStack {
                        Button(action: {
                            isResult = true
                        }) {
                            Text("Rozpocznij Operację")
                        }
                        .foregroundColor(Color(UIColor(rgb: 0xD6D681)))
                        .buttonStyle(CustomButtonStyle())
                        
                        
                        if resultImage != nil {
                            resultImage?
                                .resizable()
                                .frame(width: 160, height: 160)
                        }
                    }
                    .padding(.top, 20)
                    
                    
                    HStack {
                        ZStack(alignment: .bottomLeading) {
                            Button(action: {
                                // Clear selected photos
                                isResult = false
                                resultImage = nil
                                image1 = nil
                                image2 = nil
                            }) {
                                Text("Reset")
                            }
                            .position(x:75, y:UIScreen.main.bounds.height - 730)
                            .buttonStyle(CustomButtonStyle()) // Apply custom button style
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
        @Binding var image: Image?
        
        var body: some View {
            VStack {
                Button(action: {
                    // Implement code to allow the user to select an image
                    // and set the 'image' binding to the selected image.
                }) {
                    if let image = image {
                        image
                            .resizable()
                            .frame(width: 160, height: 160)
                    } else {
                        Image(systemName: "photo.fill") // You can use any system symbol here
                            .resizable()
                            .frame(width: 160, height: 160)
                            .foregroundColor(Color(UIColor(rgb: 0xE5E9E1))) // Customize
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
    @Binding var image1: Image?
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
    @Binding var image: Image?
    
    var body: some View {
        ImagePicker(isCameraSource: true, image: $image)
    }
}

struct PhotoLibraryView: View {
    @Binding var image: Image?
    
    var body: some View {
        ImagePicker(isCameraSource: false, image: $image)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var isCameraSource: Bool
    @Binding var image: Image?
    
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
                parent.image = Image(uiImage: uiImage)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// button Style
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
