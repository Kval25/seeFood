//
//  ViewController.swift
//  seefood
//
//  Created by REAL  on 21/03/26.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
 
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                print("Conversion failed")
                return
            }
            
            picker.dismiss(animated: true, completion: nil)
            
            detect(image: ciimage) 
        }
    }
    
    
    func detect(image: CIImage){
        
        let config = MLModelConfiguration()
        
        guard let coreMLModel = try? Resnet50(configuration: config).model else {
            print("Model loading failed")
            return
        }
        
        guard let model = try? VNCoreMLModel(for: coreMLModel) else {
            print("Vision model failed")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Processing failed")
                return
            }
            
            if let firstResult = results.first {
                DispatchQueue.main.async {
                    if firstResult.identifier.contains("hotdog") {
                        self.navigationItem.title = "Hotdog!"
                    } else {
                        self.navigationItem.title = "Not HotDog!"
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

