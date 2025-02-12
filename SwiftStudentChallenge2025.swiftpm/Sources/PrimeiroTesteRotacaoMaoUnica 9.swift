//
// PrimeiroTesteRotacaoMaoUnica_9.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class PrimeiroTesteRotacaoMaoUnica_9Input : MLFeatureProvider {

    /// A sequence of hand poses to classify. Its multiarray encoding uses the first dimension to index time over 30 frames. The second dimension indexes x, y, and confidence of hand pose keypoint locations. The last dimension indexes the keypoint type, ordered as wrist, thumbCMC, thumbMP, thumbIP, thumbTip, indexMCP, indexPIP, indexDIP, indexTip, middleMCP, middlePIP, middleDIP, middleTip, ringMCP, ringPIP, ringDIP, ringTip, littleMCP, littlePIP, littleDIP, littleTip. as 30 × 3 × 21 3-dimensional array of floats
    var poses: MLMultiArray

    var featureNames: Set<String> { ["poses"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "poses" {
            return MLFeatureValue(multiArray: poses)
        }
        return nil
    }

    init(poses: MLMultiArray) {
        self.poses = poses
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    convenience init(poses: MLShapedArray<Float>) {
        self.init(poses: MLMultiArray(poses))
    }

}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class PrimeiroTesteRotacaoMaoUnica_9Output : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// A dictionary of labels and the corresponding confidences. as dictionary of strings to doubles
    var labelProbabilities: [String : Double] {
        provider.featureValue(for: "labelProbabilities")!.dictionaryValue as! [String : Double]
    }

    /// Most likely hand action category. as string value
    var label: String {
        provider.featureValue(for: "label")!.stringValue
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(labelProbabilities: [String : Double], label: String) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["labelProbabilities" : MLFeatureValue(dictionary: labelProbabilities as [AnyHashable : NSNumber]), "label" : MLFeatureValue(string: label)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
class PrimeiroTesteRotacaoMaoUnica_9 {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "PrimeiroTesteRotacaoMaoUnica 9", withExtension:"mlmodelc")!
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of PrimeiroTesteRotacaoMaoUnica_9.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `PrimeiroTesteRotacaoMaoUnica_9.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<PrimeiroTesteRotacaoMaoUnica_9, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> PrimeiroTesteRotacaoMaoUnica_9 {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<PrimeiroTesteRotacaoMaoUnica_9, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(PrimeiroTesteRotacaoMaoUnica_9(model: model)))
            }
        }
    }

    /**
        Construct PrimeiroTesteRotacaoMaoUnica_9 instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> PrimeiroTesteRotacaoMaoUnica_9 {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return PrimeiroTesteRotacaoMaoUnica_9(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as PrimeiroTesteRotacaoMaoUnica_9Input

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as PrimeiroTesteRotacaoMaoUnica_9Output
    */
    func prediction(input: PrimeiroTesteRotacaoMaoUnica_9Input) throws -> PrimeiroTesteRotacaoMaoUnica_9Output {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as PrimeiroTesteRotacaoMaoUnica_9Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as PrimeiroTesteRotacaoMaoUnica_9Output
    */
    func prediction(input: PrimeiroTesteRotacaoMaoUnica_9Input, options: MLPredictionOptions) throws -> PrimeiroTesteRotacaoMaoUnica_9Output {
        let outFeatures = try model.prediction(from: input, options: options)
        return PrimeiroTesteRotacaoMaoUnica_9Output(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as PrimeiroTesteRotacaoMaoUnica_9Input
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as PrimeiroTesteRotacaoMaoUnica_9Output
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: PrimeiroTesteRotacaoMaoUnica_9Input, options: MLPredictionOptions = MLPredictionOptions()) async throws -> PrimeiroTesteRotacaoMaoUnica_9Output {
        let outFeatures = try await model.prediction(from: input, options: options)
        return PrimeiroTesteRotacaoMaoUnica_9Output(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - poses: A sequence of hand poses to classify. Its multiarray encoding uses the first dimension to index time over 30 frames. The second dimension indexes x, y, and confidence of hand pose keypoint locations. The last dimension indexes the keypoint type, ordered as wrist, thumbCMC, thumbMP, thumbIP, thumbTip, indexMCP, indexPIP, indexDIP, indexTip, middleMCP, middlePIP, middleDIP, middleTip, ringMCP, ringPIP, ringDIP, ringTip, littleMCP, littlePIP, littleDIP, littleTip. as 30 × 3 × 21 3-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as PrimeiroTesteRotacaoMaoUnica_9Output
    */
    func prediction(poses: MLMultiArray) throws -> PrimeiroTesteRotacaoMaoUnica_9Output {
        let input_ = PrimeiroTesteRotacaoMaoUnica_9Input(poses: poses)
        return try prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - poses: A sequence of hand poses to classify. Its multiarray encoding uses the first dimension to index time over 30 frames. The second dimension indexes x, y, and confidence of hand pose keypoint locations. The last dimension indexes the keypoint type, ordered as wrist, thumbCMC, thumbMP, thumbIP, thumbTip, indexMCP, indexPIP, indexDIP, indexTip, middleMCP, middlePIP, middleDIP, middleTip, ringMCP, ringPIP, ringDIP, ringTip, littleMCP, littlePIP, littleDIP, littleTip. as 30 × 3 × 21 3-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as PrimeiroTesteRotacaoMaoUnica_9Output
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func prediction(poses: MLShapedArray<Float>) throws -> PrimeiroTesteRotacaoMaoUnica_9Output {
        let input_ = PrimeiroTesteRotacaoMaoUnica_9Input(poses: poses)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [PrimeiroTesteRotacaoMaoUnica_9Input]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [PrimeiroTesteRotacaoMaoUnica_9Output]
    */
    func predictions(inputs: [PrimeiroTesteRotacaoMaoUnica_9Input], options: MLPredictionOptions = MLPredictionOptions()) throws -> [PrimeiroTesteRotacaoMaoUnica_9Output] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [PrimeiroTesteRotacaoMaoUnica_9Output] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  PrimeiroTesteRotacaoMaoUnica_9Output(features: outProvider)
            results.append(result)
        }
        return results
    }
}
