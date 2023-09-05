import Foundation
import SwiftUI
import Photos

struct FullScreenImageView: View {
    @Binding var resultImage: UIImage?
    @Binding var isResult: Bool

    var body: some View {
            ZStack {
            Color.black 
                            .edgesIgnoringSafeArea(.all)
              if let image = resultImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("No Image Available")
                    .foregroundColor(.white)
            }
                VStack (alignment: .center){
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isResult = false
                        }) {
                            Text("Zamknij")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                        .padding(.trailing, 170)

                        Button(action: {
                            saveImageToLibrary(resultImage)
                        }) {
                            Text("Zapisz")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                }
            }
        .edgesIgnoringSafeArea(.all)
    }
    private func saveImageToLibrary(_ image: UIImage?) {
            guard let image = image else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    print("Image saved to library")
                } else if let error = error {
                    print("Error saving image: \(error.localizedDescription)")
                }
            }
        }
}
