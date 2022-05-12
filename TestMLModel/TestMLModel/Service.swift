//
//  Service.swift
//  TextMLModel
//
//  Created by Evgeny Schwarzkopf on 05.05.2022.
//

import UIKit
import Vision

enum ImageClassifierServiceState {
    case startRequest, requestFailed, receiveResult(resultModel: [ClassifierResultModel])
}

class ImageClassifierService {
    var onDidUpdateState: ((ImageClassifierServiceState) -> Void)?

    func classifyImage(_ image: UIImage) {
        onDidUpdateState?(.startRequest)

        guard let model = makeImageClassifierModel(), let ciImage = CIImage(image: image) else {
            onDidUpdateState?(.requestFailed)
            return
        }
        makeClassifierRequest(for: model, ciImage: ciImage)
    }

    private func makeImageClassifierModel() -> VNCoreMLModel? {
        return try? VNCoreMLModel(for: ImageClassifier().model)
    }

    private func makeClassifierRequest(for model: VNCoreMLModel, ciImage: CIImage) {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            self?.handleClassifierResults(request.results)
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                self.onDidUpdateState?(.requestFailed)
            }
        }
    }

    private func handleClassifierResults(_ results: [Any]?) {
        guard let results = results as? [VNClassificationObservation] else {
                  onDidUpdateState?(.requestFailed)
                  return
              }

        DispatchQueue.main.async { [weak self] in
            let resultsModel: [ClassifierResultModel] = results.compactMap { result in
                let confidence = (result.confidence * 100).rounded()
                guard confidence > 0 else {
                    return nil
                }
                return ClassifierResultModel(identifier: result.identifier, confidence: Int(confidence))
            }
            self?.onDidUpdateState?(.receiveResult(resultModel: resultsModel))
        }
    }
}
