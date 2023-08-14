function validateFixedSizeSequenceLength(obj,layer,inputs)






%#codegen


    coder.allowpcode('plain');
    isLayerInputSequenceData=coder.const(@feval,'isLayerInputSequenceData',obj.DLCustomCoderNetwork,layer.Name);

    if isLayerInputSequenceData
        for iSource=1:numel(inputs)
            inputSize=size(inputs{iSource});
            coder.internal.assert(coder.internal.isConst(inputSize(end)),...
            "dlcoder_spkg:cnncodegen:VarsizeCustomLayerNotSupported",layer.Name);
        end
    end
end
