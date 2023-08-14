function[inDataType,outDataType,quantizedLearnablesMap]=getQuantizedParameters(layer,...
    quantizationSpecification,fiMathObject)





    assert(isa(layer,'nnet.cnn.layer.Convolution2DLayer'));

    assert(~isempty(fiMathObject));

    layerQuantizationSpec=quantizationSpecification(layer.Name);

    inSpecType=layerQuantizationSpec.getValueConfig('in1').Emulation.DataType;

    value=[];
    isSigned=true;
    slopeAdjustmentFactor=1;
    fiBiasVal=0;


    inDataType=fi(value,isSigned,inSpecType.WordLength,slopeAdjustmentFactor,...
    inSpecType.ScalingExponent,fiBiasVal,fiMathObject);




    outSpecType=layerQuantizationSpec.getValueConfig('Activations').Emulation.DataType;
    outSpecCodegen=layerQuantizationSpec.getValueConfig('Activations').Codegen;
    outDataType=fi(value,isSigned,outSpecType.WordLength,slopeAdjustmentFactor,...
    outSpecCodegen.ScalingExponent,fiBiasVal,fiMathObject);

    weightsSpecType=layerQuantizationSpec.ValueConfigs('Weights').Emulation.DataType;
    weights=layer.Weights;
    if isa(weights,'nnet.internal.cnn.layer.learnable.PredictionLearnableParameter')

        weights=weights.Value;
    end
    weights=fi(weights,isSigned,weightsSpecType.WordLength,slopeAdjustmentFactor,...
    weightsSpecType.ScalingExponent,fiBiasVal,fiMathObject);

    biasSpecType=layerQuantizationSpec.ValueConfigs('Bias').Emulation.DataType;
    bias=layer.Bias;
    if isa(bias,'nnet.internal.cnn.layer.learnable.PredictionLearnableParameter')
        bias=bias.Value;
    end
    bias=fi(bias,isSigned,biasSpecType.WordLength,slopeAdjustmentFactor,...
    biasSpecType.RescalingExponent,fiBiasVal,fiMathObject);

    quantizedLearnablesMap=containers.Map;
    quantizedLearnablesMap("Weights")=weights;
    quantizedLearnablesMap("Bias")=bias;

end
