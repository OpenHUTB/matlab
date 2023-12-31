




classdef SupportedLayers<handle
    properties(Constant,Access=public)
        m_sourceFiles=dltargets.internal.SupportedLayers.getSourceFiles();
        m_headerFiles=dltargets.internal.SupportedLayers.getHeaderFiles();
        rootDir=fullfile(matlabroot,...
        'toolbox','shared_dl_targets_src','api','layer');
        rootHeaderDir=fullfile(dltargets.internal.SupportedLayers.rootDir,...
        'export','include','layer');
    end

    methods(Static=true)

        function sourceFiles=getSourceFiles()
            sourceFiles=containers.Map();
            sourceFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWInputLayer.cpp');
            sourceFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWReLULayer.cpp');
            sourceFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWNormLayer.cpp');
            sourceFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWAvgPoolingLayer.cpp');
            sourceFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWFCLayer.cpp');
            sourceFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWMaxPoolingLayer.cpp');
            sourceFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSoftmaxLayer.cpp');
            sourceFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWOutputLayer.cpp');
            sourceFiles('gpucoder.pass_through_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWPassthroughLayer.cpp');
            sourceFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWConvLayer.cpp');
            sourceFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWLeakyReLULayer.cpp');
            sourceFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWClippedReLULayer.cpp');
            sourceFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWBatchNormalizationLayer.cpp');
            sourceFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWTransposedConvolution2DLayer.cpp');
            sourceFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWAdditionLayer.cpp');
            sourceFiles('gpucoder.MaxUnpool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWMaxUnpoolingLayer.cpp');
            sourceFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWFusedConvActivationLayer.cpp');
            sourceFiles('MWScalingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWScalingLayer.cpp');
            sourceFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWFlattenCStyleLayer.cpp');
            sourceFiles('MWSigmoidLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSigmoidLayer.cpp');
            sourceFiles('MWTanhLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWTanhLayer.cpp');
            sourceFiles('MWELULayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWELULayer.cpp');
            sourceFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWYoloReorg2dLayer.cpp');
            sourceFiles('MWCrop2dLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWCrop2dLayer.cpp');
            sourceFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWZeroPaddingLayer.cpp');
            sourceFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWYoloExtractionLayer.cpp');
            sourceFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWYoloSoftmaxLayer.cpp');
            sourceFiles('MWExponentialLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWExponentialLayer.cpp');
            sourceFiles('gpucoder.MWBfpScaleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWBfpScaleLayer.cpp');
            sourceFiles('gpucoder.MWBfpRescaleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWBfpRescaleLayer.cpp');
            sourceFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWRowMajorFlattenLayer.cpp');
            sourceFiles('MWFlattenLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWFlattenLayer.cpp');
            sourceFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSequenceInputLayer.cpp');
            sourceFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWRNNLayer.cpp');
            sourceFiles('MWSplittingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSplittingLayer.cpp');
            sourceFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWElementwiseAffineLayer.cpp');
            sourceFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWWordEmbeddingLayer.cpp');
            sourceFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSSDMergeLayer.cpp');
            sourceFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWConcatenationLayer.cpp');
            sourceFiles('gpucoder.sequence_folding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSequenceFoldingLayer.cpp');
            sourceFiles('gpucoder.sequence_unfolding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWSequenceUnfoldingLayer.cpp');
            sourceFiles('gpucoder.MWInt8DataReorderLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootDir,'MWInt8DataReorderLayer.cpp');
        end


        function headerFiles=getHeaderFiles()
            headerFiles=containers.Map();
            headerFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWInputLayer.hpp');
            headerFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWReLULayer.hpp');
            headerFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWNormLayer.hpp');
            headerFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWAvgPoolingLayer.hpp');
            headerFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWFCLayer.hpp');
            headerFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWMaxPoolingLayer.hpp');
            headerFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSoftmaxLayer.hpp');
            headerFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWOutputLayer.hpp');
            headerFiles('gpucoder.pass_through_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWPassthroughLayer.hpp');
            headerFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWConvLayer.hpp');
            headerFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWLeakyReLULayer.hpp');
            headerFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWClippedReLULayer.hpp');
            headerFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWBatchNormalizationLayer.hpp');
            headerFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTransposedConvolution2DLayer.hpp');
            headerFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWAdditionLayer.hpp');
            headerFiles('gpucoder.MaxUnpool_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWMaxUnpoolingLayer.hpp');
            headerFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWFusedConvActivationLayer.hpp');
            headerFiles('MWScalingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWScalingLayer.hpp');
            headerFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWFlattenCStyleLayer.hpp');
            headerFiles('MWSigmoidLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSigmoidLayer.hpp');
            headerFiles('MWTanhLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTanhLayer.hpp');
            headerFiles('MWELULayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWELULayer.hpp');
            headerFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWYoloReorg2dLayer.hpp');
            headerFiles('MWCrop2dLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWCrop2dLayer.hpp');
            headerFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWZeroPaddingLayer.hpp');
            headerFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWYoloExtractionLayer.hpp');
            headerFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWYoloSoftmaxLayer.hpp');
            headerFiles('MWExponentialLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWExponentialLayer.hpp');
            headerFiles('gpucoder.MWBfpScaleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWBfpScaleLayer.hpp');
            headerFiles('gpucoder.MWBfpRescaleLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWBfpRescaleLayer.hpp');
            headerFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWRowMajorFlattenLayer.hpp');
            headerFiles('MWFlattenLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWFlattenLayer.hpp');
            headerFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSequenceInputLayer.hpp');
            headerFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWRNNLayer.hpp');
            headerFiles('MWSplittingLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSplittingLayer.hpp');
            headerFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWElementwiseAffineLayer.hpp');
            headerFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWWordEmbeddingLayer.hpp');
            headerFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSSDMergeLayer.hpp');
            headerFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWConcatenationLayer.hpp');
            headerFiles('gpucoder.sequence_folding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSequenceFoldingLayer.hpp');
            headerFiles('gpucoder.sequence_unfolding_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWSequenceUnfoldingLayer.hpp');
            headerFiles('gpucoder.MWInt8DataReorderLayer')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWInt8DataReorderLayer.hpp');
            headerFiles('gpucoder.conv_int8_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWInt8ConvolutionLayer.hpp');
            headerFiles('gpucoder.fused_int8_conv_activation_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWInt8ConvolutionLayer.hpp');
            headerFiles('gpucoder.fc_int8_layer_comp')=...
            fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWInt8FCLayer.hpp');
        end

    end
end
