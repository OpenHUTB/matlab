




function layerToBuilderMap=populateLayerToBuilderMap()




    layerToBuilderMap=containers.Map;
    layerToBuilderMap('nnet.cnn.layer.AdditionLayer')='AdditionCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.BiLSTMLayer')='BiLSTMCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.DropoutLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.FeatureInputLayer')='FeatureInputCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.FullyConnectedLayer')='FullyConnectedCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.FlattenLayer')='FlattenCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.GRULayer')='GRUCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ImageInputLayer')='InputCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.LSTMLayer')='LSTMCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ReLULayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SequenceInputLayer')='SequenceInputCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SigmoidLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.keras.layer.SigmoidLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.SigmoidLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SoftmaxLayer')='SoftmaxCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.TanhLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.keras.layer.TanhLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.TanhLayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ClassificationOutputLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.RegressionOutputLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.MaxPooling2DLayer')='MaxPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ELULayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('rl.layer.ScalingLayer')='ScalingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.inceptionresnetv2.layer.ScalingFactorLayer')='ScalingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.IdentityLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.VerifyBatchSizeLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.Convolution2DLayer')='ConvCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ConcatenationLayer')='ConcatenationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.DepthConcatenationLayer')='ConcatenationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.ClippedReLULayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.LeakyReLULayer')='ActivationCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.ElementwiseAffineLayer')='ElementWiseAffineCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.FlattenLayer')='FlattenOnnxCustomLayerClassBuilder';
    layerToBuilderMap('nnet.onnx.layer.GlobalAveragePooling2dLayer')='AvgPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.keras.layer.GlobalAveragePooling2dLayer')='AvgPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.keras.layer.FlattenCStyleLayer')='FlattenCStyleCustomLayerClassBuilder';
    layerToBuilderMap('nnet.keras.layer.ZeroPadding2dLayer')='ZeroPadding2dCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.BatchNormalizationLayer')='BatchNormCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.AveragePooling2DLayer')='AvgPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.GlobalAveragePooling2DLayer')='AvgPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.GlobalMaxPooling2DLayer')='MaxPoolingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.FocalLossLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.AnchorBoxLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.RCNNBoxRegressionLayer')='PassThroughCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SSDMergeLayer')='SSDMergeCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SequenceFoldingLayer')='SequenceFoldingCustomLayerClassBuilder';
    layerToBuilderMap('nnet.cnn.layer.SequenceUnfoldingLayer')='SequenceUnfoldingCustomLayerClassBuilder';
end
