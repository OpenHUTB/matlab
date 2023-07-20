function FCConvertedToConv=isFCConvertedToConv(layer,networkInfo)












    FCConvertedToConv=false;
    if isa(layer,'nnet.cnn.layer.FullyConnectedLayer')||isa(layer,'nnet.internal.cnn.coder.layer.FullyConnectedActivation')



        isImageInputSize=cellfun(@(dimensions)numel(dimensions)==3,networkInfo.InputLayerSizes);
        hasSpatialInputs=any(isImageInputSize);
        if hasSpatialInputs
            networkInputHWfun=@()cellfun(@(sizes)iExtractSpatialDims(sizes),networkInfo.InputLayerSizes(isImageInputSize),'UniformOutput',false);
            codegenInputHWfun=@()cellfun(@(sizes)iExtractSpatialDims(sizes),networkInfo.CodegenInputSizes(isImageInputSize),'UniformOutput',false);

            if~isequal(codegenInputHWfun(),networkInputHWfun())
                FCConvertedToConv=true;
            end
        end
    end
end

function HW=iExtractSpatialDims(sizes)




    assert(numel(sizes)>=3);
    HW=sizes([1,2]);
end
