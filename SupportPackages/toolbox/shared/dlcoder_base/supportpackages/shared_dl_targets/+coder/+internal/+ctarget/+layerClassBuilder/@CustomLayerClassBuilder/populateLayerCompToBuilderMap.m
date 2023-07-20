

function layerCompToBuilderMap=populateLayerCompToBuilderMap()




    layerCompToBuilderMap=containers.Map;
    layerCompToBuilderMap('gpucoder.addition_layer_comp')='AdditionCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.fc_layer_comp')='FullyConnectedCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.relu_layer_comp')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.sequence_input_layer_comp')='SequenceInputCustomLayerClassBuilder';
    layerCompToBuilderMap('MWSigmoidLayer')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.softmax_layer_comp')='SoftmaxCustomLayerClassBuilder';
    layerCompToBuilderMap('MWTanhLayer')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.output_layer_comp')='PassThroughCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.max_pool_layer_comp')='MaxPoolingCustomLayerClassBuilder';
    layerCompToBuilderMap('MWELULayer')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('MWScalingLayer')='ScalingCustomLayerClassBuilder';
    layerCompToBuilderMap('MWFlattenLayer')='FlattenCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.fused_conv_activation_layer_comp')='ConvActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.concatenation_layer_comp')='ConcatenationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.clippedrelu_layer_comp')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.leakyrelu_layer_comp')='ActivationCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.batch_norm_layer_comp')='BatchNormCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.avg_pool_layer_comp')='AvgPoolingCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.sequence_folding_layer_comp')='SequenceFoldingCustomLayerClassBuilder';
    layerCompToBuilderMap('gpucoder.sequence_unfolding_layer_comp')='SequenceUnfoldingCustomLayerClassBuilder';
end
