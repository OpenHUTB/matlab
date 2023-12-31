



classdef SupportedLayerImpl<handle
    properties(Constant,Access=public)
        m_supportedLayers=dltargets.onednn.SupportedLayerImpl.initSupportedLayers();
        m_sourceFiles=dltargets.onednn.SupportedLayerImpl.getSourceFiles();
        m_headerFiles=dltargets.onednn.SupportedLayerImpl.getHeaderFiles();
        componentRootDir=fullfile(matlabroot,'toolbox','matlabcoder_dl_targets_src');
        rootDir=fullfile(dltargets.onednn.SupportedLayerImpl.componentRootDir,'onednn');
        rootHeaderDir=fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,...
        'export','include','onednn');
    end

    methods(Static=true)

        function supportedLayers=initSupportedLayers()

            supportedLayers={'gpucoder.avg_pool_layer_comp',...
            'gpucoder.max_pool_layer_comp',...
            'gpucoder.input_layer_comp',...
            'gpucoder.conv_layer_comp',...
            'gpucoder.norm_layer_comp',...
            'gpucoder.output_layer_comp',...
            'gpucoder.fc_layer_comp',...
            'gpucoder.relu_layer_comp',...
            'gpucoder.leakyrelu_layer_comp',...
            'gpucoder.softmax_layer_comp',...
            'gpucoder.pass_through_layer_comp',...
            'gpucoder.addition_layer_comp',...
            'gpucoder.clippedrelu_layer_comp',...
            'gpucoder.batch_norm_layer_comp',...
            'gpucoder.transposedconv_layer_comp',...
            'gpucoder.fused_conv_activation_layer_comp',...
            'gpucoder.MaxUnpool_layer_comp',...
            'MWScalingLayer',...
            'MWCrop2dLayer',...
            'MWSigmoidLayer',...
            'MWYoloReorg2dLayer',...
            'MWYoloTransformLayer',...
            'MWYoloExtractionLayer',...
            'MWYoloSoftmaxLayer',...
            'MWExponentialLayer',...
            'MWELULayer',...
            'MWFlattenCStyleLayer',...
            'MWTanhLayer',...
            'MWZeroPaddingLayer',...
            'MWRowMajorFlattenLayer',...
            'MWSplittingLayer',...
            'gpucoder.concatenation_layer_comp',...
            'gpucoder.ssdMergeLayer',...
            'gpucoder.elementwise_affine_layer_comp',...
            'gpucoder.sequence_input_layer_comp',...
            'gpucoder.rnn_layer_comp',...
            'gpucoder.word_embedding_layer_comp',...
            'gpucoder.sequence_folding_layer_comp',...
            'gpucoder.sequence_unfolding_layer_comp',...
            'MWFlattenLayer',...
            };
        end

        function sourceFiles=getSourceFiles()
            keys=dltargets.onednn.SupportedLayerImpl.m_supportedLayers;
            values=cell(numel(keys),1);
            sourceFiles=containers.Map(keys,values);
            sourceFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnInputLayerImpl.cpp');
            sourceFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnReLULayerImpl.cpp');
            sourceFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnNormLayerImpl.cpp');
            sourceFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnAvgPoolingLayerImpl.cpp');
            sourceFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnFCLayerImpl.cpp');
            sourceFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnMaxPoolingLayerImpl.cpp');
            sourceFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSoftmaxLayerImpl.cpp');
            sourceFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnOutputLayerImpl.cpp');
            sourceFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnLeakyReLULayerImpl.cpp');
            sourceFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnClippedReLULayerImpl.cpp');
            sourceFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnBatchNormalizationLayerImpl.cpp');
            sourceFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnTransposedConvolution2DLayerImpl.cpp');
            sourceFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnAdditionLayerImpl.cpp');
            sourceFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnConvLayerImpl.cpp');
            sourceFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnFusedConvActivationLayerImpl.cpp');
            sourceFiles('gpucoder.MaxUnpool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnMaxUnpoolingLayerImpl.cpp');
            sourceFiles('MWScalingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnScalingLayerImpl.cpp');
            sourceFiles('MWCrop2dLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnCrop2dLayerImpl.cpp');
            sourceFiles('MWSigmoidLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSigmoidLayerImpl.cpp');
            sourceFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnYoloReorg2dLayerImpl.cpp');
            sourceFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnYoloExtractionLayerImpl.cpp');
            sourceFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnYoloSoftmaxLayerImpl.cpp');
            sourceFiles('MWExponentialLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnExponentialLayerImpl.cpp');
            sourceFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnFlattenCStyleLayerImpl.cpp');
            sourceFiles('MWTanhLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnTanhLayerImpl.cpp');
            sourceFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnZeroPaddingLayerImpl.cpp');
            sourceFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnRowMajorFlattenLayerImpl.cpp');
            sourceFiles('MWSplittingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSplittingLayerImpl.cpp');
            sourceFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnElementwiseAffineLayerImpl.cpp');
            sourceFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnConcatenationLayerImpl.cpp');
            sourceFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSSDMergeLayerImpl.cpp');
            sourceFiles('MWELULayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnELULayerImpl.cpp');
            sourceFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSequenceInputLayerImpl.cpp');
            sourceFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnRNNLayerImpl.cpp');
            sourceFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnWordEmbeddingLayerImpl.cpp');
            sourceFiles('MWFlattenLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnFlattenLayerImpl.cpp');
            sourceFiles('gpucoder.sequence_folding_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootDir,'MWOnednnSequenceFoldingLayerImpl.cpp');
        end

        function headerFiles=getHeaderFiles()
            keys=dltargets.onednn.SupportedLayerImpl.m_supportedLayers;
            values=cell(numel(keys),1);
            headerFiles=containers.Map(keys,values);
            headerFiles('gpucoder.input_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnInputLayerImpl.hpp');
            headerFiles('gpucoder.relu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnReLULayerImpl.hpp');
            headerFiles('gpucoder.norm_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnNormLayerImpl.hpp');
            headerFiles('gpucoder.avg_pool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnAvgPoolingLayerImpl.hpp');
            headerFiles('gpucoder.fc_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnFCLayerImpl.hpp');
            headerFiles('gpucoder.max_pool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnMaxPoolingLayerImpl.hpp');
            headerFiles('gpucoder.softmax_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSoftmaxLayerImpl.hpp');
            headerFiles('gpucoder.output_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnOutputLayerImpl.hpp');
            headerFiles('gpucoder.leakyrelu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnLeakyReLULayerImpl.hpp');
            headerFiles('gpucoder.conv_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnConvLayerImpl.hpp');
            headerFiles('gpucoder.clippedrelu_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnClippedReLULayerImpl.hpp');
            headerFiles('gpucoder.batch_norm_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnBatchNormalizationLayerImpl.hpp');
            headerFiles('gpucoder.transposedconv_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnTransposedConvolution2DLayerImpl.hpp');
            headerFiles('gpucoder.addition_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnAdditionLayerImpl.hpp');
            headerFiles('gpucoder.fused_conv_activation_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnFusedConvActivationLayerImpl.hpp');
            headerFiles('gpucoder.MaxUnpool_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnMaxUnpoolingLayerImpl.hpp');
            headerFiles('MWScalingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnScalingLayerImpl.hpp');
            headerFiles('MWCrop2dLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnCrop2dLayerImpl.hpp');
            headerFiles('MWSigmoidLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSigmoidLayerImpl.hpp');
            headerFiles('MWYoloReorg2dLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnYoloReorg2dLayerImpl.hpp');
            headerFiles('MWYoloExtractionLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnYoloExtractionLayerImpl.hpp');
            headerFiles('MWYoloSoftmaxLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnYoloSoftmaxLayerImpl.hpp');
            headerFiles('MWExponentialLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnExponentialLayerImpl.hpp');
            headerFiles('MWFlattenCStyleLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnFlattenCStyleLayerImpl.hpp');
            headerFiles('MWTanhLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnTanhLayerImpl.hpp');
            headerFiles('MWZeroPaddingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnZeroPaddingLayerImpl.hpp');
            headerFiles('MWRowMajorFlattenLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnRowMajorFlattenLayerImpl.hpp');
            headerFiles('MWSplittingLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSplittingLayerImpl.hpp');
            headerFiles('gpucoder.elementwise_affine_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnElementwiseAffineLayerImpl.hpp');
            headerFiles('gpucoder.concatenation_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnConcatenationLayerImpl.hpp');
            headerFiles('gpucoder.ssdMergeLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSSDMergeLayerImpl.hpp');
            headerFiles('MWELULayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnELULayerImpl.hpp');
            headerFiles('gpucoder.sequence_input_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSequenceInputLayerImpl.hpp');
            headerFiles('gpucoder.rnn_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnRNNLayerImpl.hpp');
            headerFiles('gpucoder.word_embedding_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnWordEmbeddingLayerImpl.hpp');
            headerFiles('MWFlattenLayer')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnFlattenLayerImpl.hpp');
            headerFiles('gpucoder.sequence_folding_layer_comp')=...
            fullfile(dltargets.onednn.SupportedLayerImpl.rootHeaderDir,'MWOnednnSequenceFoldingLayerImpl.hpp');
        end

    end


end


