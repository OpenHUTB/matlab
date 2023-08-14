





classdef SupportedLayerImpl<handle
    properties(Constant,Access=public)
        m_supportedLayers=dltargets.arm_neon.SupportedLayerImpl.initSupportedLayers();
        m_sourceFiles=dltargets.arm_neon.SupportedLayerImpl.getSourceFiles();
        m_headerFiles=dltargets.arm_neon.SupportedLayerImpl.getHeaderFiles();
        componentRootDir=fullfile(matlabroot,'toolbox','matlabcoder_dl_targets_src');
        rootDir=fullfile(dltargets.arm_neon.SupportedLayerImpl.componentRootDir,'arm_neon');
    end

    methods(Static=true)

        function rootDir=getInstallDir
            [flag,rootDir]=dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
            assert(flag);
            assert(~isempty(rootDir));
        end

        function supportedLayers=initSupportedLayers()

            supportedLayers={'gpucoder.input_layer_comp',...
            'gpucoder.conv_layer_comp',...
            'gpucoder.output_layer_comp',...
            'gpucoder.relu_layer_comp',...
            'gpucoder.norm_layer_comp',...
            'gpucoder.max_pool_layer_comp',...
            'gpucoder.softmax_layer_comp',...
            'gpucoder.fc_layer_comp',...
            'gpucoder.pass_through_layer_comp',...
            'gpucoder.addition_layer_comp',...
            'gpucoder.batch_norm_layer_comp',...
            'gpucoder.avg_pool_layer_comp',...
            'gpucoder.fused_conv_activation_layer_comp',...
            'gpucoder.leakyrelu_layer_comp',...
            'gpucoder.clippedrelu_layer_comp',...
            'gpucoder.transposedconv_layer_comp',...
            'MWCrop2dLayer',...
            'MWScalingLayer',...
'MWYoloTransformLayer'...
            ,'MWYoloExtractionLayer',...
            'MWSigmoidLayer',...
            'MWYoloSoftmaxLayer',...
            'MWExponentialLayer',...
            'MWYoloReorg2dLayer',...
            'MWFlattenCStyleLayer',...
            'MWTanhLayer',...
            'MWZeroPaddingLayer',...
            'MWRowMajorFlattenLayer',...
            'MWSplittingLayer',...
            'gpucoder.elementwise_affine_layer_comp',...
            'gpucoder.sequence_input_layer_comp',...
            'gpucoder.concatenation_layer_comp',...
            'gpucoder.rnn_layer_comp',...
            'gpucoder.ssdMergeLayer',...
            'MWELULayer',...
            'gpucoder.word_embedding_layer_comp',...
            'gpucoder.sequence_folding_layer_comp',...
            'gpucoder.sequence_unfolding_layer_comp',...
            'MWFlattenLayer',...
            'gpucoder.conv_int8_layer_comp',...
            'gpucoder.fused_int8_conv_activation_layer_comp',...
            'gpucoder.MWBfpScaleLayer',...
            'gpucoder.MWBfpRescaleLayer',...
            'gpucoder.fc_int8_layer_comp',
            };
        end

        function sourceFiles=getSourceFiles()
            keys=dltargets.arm_neon.SupportedLayerImpl.m_supportedLayers;
            values=cell(numel(keys),1);
            sourceFiles=containers.Map(keys,values);
            sourceFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInputLayerImpl.cpp');
            sourceFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonReLULayerImpl.cpp');
            sourceFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonNormLayerImpl.cpp');
            sourceFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonAvgPoolingLayerImpl.cpp');
            sourceFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFCLayerImpl.cpp');
            sourceFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonMaxPoolingLayerImpl.cpp');
            sourceFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSoftmaxLayerImpl.cpp');
            sourceFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonOutputLayerImpl.cpp');
            sourceFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonAdditionLayerImpl.cpp');
            sourceFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBatchNormalizationLayerImpl.cpp');
            sourceFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonConvLayerImpl.cpp');
            sourceFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFusedConvActivationLayerImpl.cpp');
            sourceFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonLeakyReLULayerImpl.cpp');
            sourceFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonClippedReLULayerImpl.cpp');
            sourceFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonTransposedConvolution2DLayerImpl.cpp');
            sourceFiles('MWScalingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonScalingLayerImpl.cpp');
            sourceFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloExtractionLayerImpl.cpp');
            sourceFiles('MWSigmoidLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSigmoidLayerImpl.cpp');
            sourceFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloSoftmaxLayerImpl.cpp');
            sourceFiles('MWExponentialLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonExponentialLayerImpl.cpp');
            sourceFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloReorg2dLayerImpl.cpp');
            sourceFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFlattenCStyleLayerImpl.cpp');
            sourceFiles('MWTanhLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonTanhLayerImpl.cpp');
            sourceFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonZeroPaddingLayerImpl.cpp');
            sourceFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonRowMajorFlattenLayerImpl.cpp');
            sourceFiles('MWSplittingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSplittingLayerImpl.cpp');
            sourceFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonElementwiseAffineLayerImpl.cpp');
            sourceFiles('MWCrop2dLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonCrop2dLayerImpl.cpp');
            sourceFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSequenceInputLayerImpl.cpp');
            sourceFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonConcatenationLayerImpl.cpp');
            sourceFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonRNNLayerImpl.cpp');
            sourceFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSSDMergeLayerImpl.cpp');
            sourceFiles('MWELULayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonELULayerImpl.cpp');
            sourceFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonWordEmbeddingLayerImpl.cpp');
            sourceFiles('MWFlattenLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFlattenLayerImpl.cpp');
            sourceFiles('gpucoder.conv_int8_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8ConvolutionLayerImpl.cpp');
            sourceFiles('gpucoder.fused_int8_conv_activation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8ConvolutionLayerImpl.cpp');
            sourceFiles('gpucoder.MWBfpScaleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBfpScaleLayerImpl.cpp');
            sourceFiles('gpucoder.MWBfpRescaleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBfpRescaleLayerImpl.cpp');
            sourceFiles('gpucoder.fc_int8_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8FCLayerImpl.cpp');
        end

        function headerFiles=getHeaderFiles()
            keys=dltargets.arm_neon.SupportedLayerImpl.m_supportedLayers;
            values=cell(numel(keys),1);
            headerFiles=containers.Map(keys,values);
            headerFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInputLayerImpl.hpp');
            headerFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonReLULayerImpl.hpp');
            headerFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonNormLayerImpl.hpp');
            headerFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonAvgPoolingLayerImpl.hpp');
            headerFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFCLayerImpl.hpp');
            headerFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonMaxPoolingLayerImpl.hpp');
            headerFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSoftmaxLayerImpl.hpp');
            headerFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonOutputLayerImpl.hpp');
            headerFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonConvLayerImpl.hpp');
            headerFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonAdditionLayerImpl.hpp');
            headerFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBatchNormalizationLayerImpl.hpp');
            headerFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFusedConvActivationLayerImpl.hpp');
            headerFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonLeakyReLULayerImpl.hpp');
            headerFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonClippedReLULayerImpl.hpp');
            headerFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonTransposedConvolution2DLayerImpl.hpp');
            headerFiles('MWScalingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonScalingLayerImpl.hpp');
            headerFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloExtractionLayerImpl.hpp');
            headerFiles('MWSigmoidLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSigmoidLayerImpl.hpp');
            headerFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloSoftmaxLayerImpl.hpp');
            headerFiles('MWExponentialLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonExponentialLayerImpl.hpp');
            headerFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonYoloReorg2dLayerImpl.hpp');
            headerFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFlattenCStyleLayerImpl.hpp');
            headerFiles('MWTanhLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonTanhLayerImpl.hpp');
            headerFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonZeroPaddingLayerImpl.hpp');
            headerFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonRowMajorFlattenLayerImpl.hpp');
            headerFiles('MWSplittingLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSplittingLayerImpl.hpp');
            headerFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonElementwiseAffineLayerImpl.hpp');
            headerFiles('MWCrop2dLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonCrop2dLayerImpl.hpp');
            headerFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSequenceInputLayerImpl.hpp');
            headerFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonRNNLayerImpl.hpp');
            headerFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonConcatenationLayerImpl.hpp');
            headerFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonSSDMergeLayerImpl.hpp');
            headerFiles('MWELULayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonELULayerImpl.hpp');
            headerFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonWordEmbeddingLayerImpl.hpp');
            headerFiles('MWFlattenLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonFlattenLayerImpl.hpp');
            headerFiles('gpucoder.fused_int8_conv_activation_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8ConvolutionLayerImpl.hpp');
            headerFiles('gpucoder.conv_int8_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8ConvolutionLayerImpl.hpp');
            headerFiles('gpucoder.MWBfpScaleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBfpScaleLayerImpl.hpp');
            headerFiles('gpucoder.MWBfpRescaleLayer')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonBfpRescaleLayerImpl.hpp');
            headerFiles('gpucoder.fc_int8_layer_comp')=...
            fullfile(dltargets.arm_neon.SupportedLayerImpl.rootDir,'MWArmneonInt8FCLayerImpl.hpp');
        end

    end
end
