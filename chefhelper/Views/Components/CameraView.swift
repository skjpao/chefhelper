import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCameraAuthorized = false
    
    var body: some View {
        Group {
            if isCameraAuthorized {
                ImagePicker(imageData: $imageData, sourceType: .camera)
                    .ignoresSafeArea()
            } else {
                ProgressView()
            }
        }
        .task {
            await checkCameraPermission()
        }
        .alert("camera_permission".localized, isPresented: $showingAlert) {
            Button("open_settings".localized) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                dismiss()
            }
            Button("cancel".localized, role: .cancel) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    @MainActor
    private func checkCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                isCameraAuthorized = true
            } else {
                alertMessage = "camera_permission_needed".localized
                showingAlert = true
            }
        case .denied, .restricted:
            alertMessage = "camera_permission_denied".localized
            showingAlert = true
        @unknown default:
            alertMessage = "camera_permission_error".localized
            showingAlert = true
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
} 
