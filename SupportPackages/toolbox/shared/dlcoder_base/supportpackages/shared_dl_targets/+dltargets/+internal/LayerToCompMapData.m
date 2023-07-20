classdef LayerToCompMapData<handle























    properties
        NonCustomLayersToCompMap containers.Map
        CustomLayersToCompMap containers.Map
    end

    methods

        function obj=LayerToCompMapData()
            buildNonCustomLayersToCompMap(obj);
            buildCustomLayersToCompMap(obj)
        end

        function buildNonCustomLayersToCompMap(obj)

            nonCustomLayersToComp=containers.Map;
            nonCustomLayersToComp('nnet.cnn.layer.AveragePooling2DLayer')=dltargets.internal.compbuilder.AvgPoolingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.MaxPooling2DLayer')=dltargets.internal.compbuilder.MaxPoolingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.ImageInputLayer')=dltargets.internal.compbuilder.InputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.Convolution2DLayer')=dltargets.internal.compbuilder.ConvCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.GroupedConvolution2DLayer')=dltargets.internal.compbuilder.GroupedConvCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.TransposedConvolution2DLayer')=dltargets.internal.compbuilder.TransposedConvCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.BatchNormalizationLayer')=dltargets.internal.compbuilder.BatchNormalizationCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.CrossChannelNormalizationLayer')=dltargets.internal.compbuilder.NormCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.ClassificationOutputLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.PixelClassificationLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.RegressionOutputLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.FullyConnectedLayer')=dltargets.internal.compbuilder.FCCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.ReLULayer')=dltargets.internal.compbuilder.ReLUCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.LeakyReLULayer')=dltargets.internal.compbuilder.LeakyReLUCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.ClippedReLULayer')=dltargets.internal.compbuilder.ClippedReLUCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SoftmaxLayer')=dltargets.internal.compbuilder.SoftmaxCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.DropoutLayer')=dltargets.internal.compbuilder.PassthroughCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.AnchorBoxLayer')=dltargets.internal.compbuilder.PassthroughCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.AdditionLayer')=dltargets.internal.compbuilder.AdditionCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.DepthConcatenationLayer')=dltargets.internal.compbuilder.DepthConcatenationCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.MaxUnpooling2DLayer')=dltargets.internal.compbuilder.MaxUnpoolingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.GlobalAveragePooling2DLayer')=dltargets.internal.compbuilder.GlobalAvgPoolingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.GlobalMaxPooling2DLayer')=dltargets.internal.compbuilder.GlobalMaxPoolingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.YOLOv2ReorgLayer')=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SpaceToDepthLayer')=dltargets.internal.compbuilder.YOLOv2ReorgCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.Crop2DLayer')=dltargets.internal.compbuilder.CropCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.YOLOv2TransformLayer')=dltargets.internal.compbuilder.YOLOv2TransformCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.YOLOv2OutputLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SequenceInputLayer')=dltargets.internal.compbuilder.SequenceInputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.LSTMLayer')=dltargets.internal.compbuilder.LSTMCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.BiLSTMLayer')=dltargets.internal.compbuilder.BiLSTMCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.WordEmbeddingLayer')=dltargets.internal.compbuilder.WordEmbeddingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.FlattenLayer')=dltargets.internal.compbuilder.FlattenCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SSDMergeLayer')=dltargets.internal.compbuilder.SSDMergeCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.ConcatenationLayer')=dltargets.internal.compbuilder.ConcatenationCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SequenceFoldingLayer')=dltargets.internal.compbuilder.SequenceFoldingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.SequenceUnfoldingLayer')=dltargets.internal.compbuilder.SequenceUnfoldingCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.GRULayer')=dltargets.internal.compbuilder.GRUCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.FocalLossLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.RCNNBoxRegressionLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.RPNClassificationLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.DicePixelClassificationLayer')=dltargets.internal.compbuilder.OutputCompBuilder.getCompKey();
            nonCustomLayersToComp('nnet.cnn.layer.FeatureInputLayer')=dltargets.internal.compbuilder.InputCompBuilder.getCompKey();
            obj.NonCustomLayersToCompMap=nonCustomLayersToComp;
        end

        function buildCustomLayersToCompMap(obj)

            customLayersToComp=containers.Map;
            customLayersToComp('nnet.onnx.layer.FlattenLayer')=dltargets.internal.compbuilder.RowMajorFlattenCompBuilder.getCompKey();
            customLayersToComp('nnet.cnn.layer.TanhLayer')=dltargets.internal.compbuilder.TanhCompBuilder.getCompKey();
            customLayersToComp('nnet.cnn.layer.ELULayer')=dltargets.internal.compbuilder.ELUCompBuilder.getCompKey();
            customLayersToComp('nnet.cnn.layer.SigmoidLayer')=dltargets.internal.compbuilder.SigmoidCompBuilder.getCompKey();
            customLayersToComp('nnet.inceptionv3.layer.ScalingLayer')=dltargets.internal.compbuilder.ScalingCompBuilder.getCompKey();
            customLayersToComp('nnet.keras.layer.FlattenCStyleLayer')=dltargets.internal.compbuilder.FlattenCStyleCompBuilder.getCompKey();
            customLayersToComp('nnet.keras.layer.SigmoidLayer')=dltargets.internal.compbuilder.SigmoidCompBuilder.getCompKey();
            customLayersToComp('nnet.keras.layer.TanhLayer')=dltargets.internal.compbuilder.TanhCompBuilder.getCompKey();
            customLayersToComp('nnet.keras.layer.GlobalAveragePooling2dLayer')=dltargets.internal.compbuilder.GlobalAvgPoolingCompBuilder.getCompKey();
            customLayersToComp('nnet.keras.layer.ZeroPadding2dLayer')=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.getCompKey();
            customLayersToComp('nnet.nasnetmobile.layer.NASNetMobileZeroPadding2dLayer')=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.getCompKey();
            customLayersToComp('nnet.nasnetlarge.layer.NASNetLargeZeroPadding2dLayer')=dltargets.internal.compbuilder.ZeroPaddingCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.ElementwiseAffineLayer')=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.GlobalAveragePooling2dLayer')=dltargets.internal.compbuilder.GlobalAvgPoolingCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.SigmoidLayer')=dltargets.internal.compbuilder.SigmoidCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.TanhLayer')=dltargets.internal.compbuilder.TanhCompBuilder.getCompKey();
            customLayersToComp('nnet.inceptionresnetv2.layer.ScalingFactorLayer')=dltargets.internal.compbuilder.ScalingFactorCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.IdentityLayer')=dltargets.internal.compbuilder.PassthroughCompBuilder.getCompKey();
            customLayersToComp('nnet.onnx.layer.VerifyBatchSizeLayer')=dltargets.internal.compbuilder.PassthroughCompBuilder.getCompKey();
            customLayersToComp('rl.layer.ScalingLayer')=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.getCompKey();
            obj.CustomLayersToCompMap=customLayersToComp;
        end
    end

end

