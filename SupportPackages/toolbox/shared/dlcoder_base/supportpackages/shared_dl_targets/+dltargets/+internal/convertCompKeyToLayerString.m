







function layerString=convertCompKeyToLayerString(compKey)





    persistent compKeyToLayerStringMap;

    if isempty(compKeyToLayerStringMap)
        compKeyToLayerStringMap=populateCompKeyToLayerStringMap();
    end

    assert(compKeyToLayerStringMap.Count>0,'compKey-to-layerString map is empty');
    if compKeyToLayerStringMap.isKey(compKey)
        layerString=compKeyToLayerStringMap(compKey);
    else
        layerString='';
    end
end

function compKeyToLayerStringMap=populateCompKeyToLayerStringMap()
    compKeyToLayerStringMap=containers.Map;

    compKeyToLayerStringMap('gpucoder.addition_layer_comp')='Addition';
    compKeyToLayerStringMap('gpucoder.avg_pool_layer_comp')='AvgPooling';
    compKeyToLayerStringMap('gpucoder.batch_norm_layer_comp')='BatchNormalization';
    compKeyToLayerStringMap('gpucoder.MWBfpRescaleLayer')='BfpRescale';
    compKeyToLayerStringMap('gpucoder.MWBfpScaleLayer')='BfpScale';
    compKeyToLayerStringMap('gpucoder.clippedrelu_layer_comp')='ClippedReLU';
    compKeyToLayerStringMap('gpucoder.concatenation_layer_comp')='Concatenation';
    compKeyToLayerStringMap('gpucoder.conv_layer_comp')='Conv';
    compKeyToLayerStringMap('MWCrop2dLayer')='Crop2d';
    compKeyToLayerStringMap('gpucoder.elementwise_affine_layer_comp')='ElementwiseAffine';
    compKeyToLayerStringMap('MWELULayer')='ELU';
    compKeyToLayerStringMap('MWExponentialLayer')='Exponential';
    compKeyToLayerStringMap('gpucoder.fc_layer_comp')='FC';
    compKeyToLayerStringMap('MWFlattenLayer')='Flatten';
    compKeyToLayerStringMap('MWFlattenCStyleLayer')='FlattenCStyle';
    compKeyToLayerStringMap('gpucoder.fused_conv_activation_layer_comp')='FusedConvActivation';
    compKeyToLayerStringMap('gpucoder.input_layer_comp')='Input';
    compKeyToLayerStringMap('gpucoder.conv_int8_layer_comp')='Int8Convolution';
    compKeyToLayerStringMap('gpucoder.fused_int8_conv_activation_layer_comp')='Int8Convolution';
    compKeyToLayerStringMap('gpucoder.fc_int8_layer_comp')='Int8FC';
    compKeyToLayerStringMap('gpucoder.MWInt8DataReorderLayer')='Int8DataReorder';
    compKeyToLayerStringMap('gpucoder.leakyrelu_layer_comp')='LeakyReLU';
    compKeyToLayerStringMap('gpucoder.max_pool_layer_comp')='MaxPooling';
    compKeyToLayerStringMap('gpucoder.MaxUnpool_layer_comp')='MaxUnpooling';
    compKeyToLayerStringMap('gpucoder.norm_layer_comp')='Norm';
    compKeyToLayerStringMap('gpucoder.output_layer_comp')='Output';
    compKeyToLayerStringMap('gpucoder.pass_through_layer_comp')='Passthrough';
    compKeyToLayerStringMap('gpucoder.relu_layer_comp')='ReLU';
    compKeyToLayerStringMap('gpucoder.rnn_layer_comp')='RNN';
    compKeyToLayerStringMap('MWRowMajorFlattenLayer')='RowMajorFlatten';
    compKeyToLayerStringMap('MWScalingLayer')='Scaling';
    compKeyToLayerStringMap('gpucoder.sequence_folding_layer_comp')='SequenceFolding';
    compKeyToLayerStringMap('gpucoder.sequence_input_layer_comp')='SequenceInput';
    compKeyToLayerStringMap('gpucoder.sequence_unfolding_layer_comp')='SequenceUnfolding';
    compKeyToLayerStringMap('MWSigmoidLayer')='Sigmoid';
    compKeyToLayerStringMap('gpucoder.softmax_layer_comp')='Softmax';
    compKeyToLayerStringMap('MWSplittingLayer')='Splitting';
    compKeyToLayerStringMap('gpucoder.ssdMergeLayer')='SSDMerge';
    compKeyToLayerStringMap('MWTanhLayer')='Tanh';
    compKeyToLayerStringMap('gpucoder.transposedconv_layer_comp')='TransposedConvolution2D';
    compKeyToLayerStringMap('gpucoder.word_embedding_layer_comp')='WordEmbedding';
    compKeyToLayerStringMap('MWYoloExtractionLayer')='YoloExtraction';
    compKeyToLayerStringMap('MWYoloReorg2dLayer')='YoloReorg2d';
    compKeyToLayerStringMap('MWYoloSoftmaxLayer')='YoloSoftmax';
    compKeyToLayerStringMap('MWZeroPaddingLayer')='ZeroPadding';
end
