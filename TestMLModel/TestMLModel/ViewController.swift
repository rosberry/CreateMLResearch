//
//  ViewController.swift
//  TextMLModel
//
//  Created by Evgeny Schwarzkopf on 05.05.2022.
//

import UIKit
import Vision

class ViewController: UIViewController {

    private let classifierService = ImageClassifierService()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        return imageView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Image", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        bindToImageClassifierService()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = .init(x: 20,
                                y: view.safeAreaInsets.top + 40,
                                width: view.bounds.width - 40,
                                height: view.bounds.height / 2 + 50)
        addButton.frame = .init(x: (view.bounds.width / 2) - 50,
                                y: imageView.bounds.maxY + 100,
                                width: 100,
                                height: 50)
        titleLabel.frame = .init(x: 20,
                                 y: imageView.bounds.maxY + 130,
                                 width: view.bounds.width - 40,
                                 height: 150)
    }

    private func bindToImageClassifierService() {
        classifierService.onDidUpdateState = { [weak self] state in
            self?.setupWithImageClassifierState(state)
        }
    }

    private func setupWithImageClassifierState(_ state: ImageClassifierServiceState) {
        titleLabel.isHidden = false
        switch state {
        case .startRequest:
            titleLabel.text = "Сlassification in progress"
        case .requestFailed:
            titleLabel.text = "Classification is failed"
        case .receiveResult(let result):
            titleLabel.text = result.map { model in
                model.description
            }.joined(separator: "\n")
        }
    }

    @objc
    private func addButtonPressed() {
        showAlert()
    }

    private func showAlert() {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showImagePicker(sourceType: .camera)
        }

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = sourceType
        present(imagePickerViewController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        let imageKey = UIImagePickerController.InfoKey.originalImage
        guard let image = info[imageKey] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
        classifierService.classifyImage(image)
        imageView.image = image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
