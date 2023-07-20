function Z=ssdMergeOperation(numInputs,numChannels,numAnchorBoxesForAllFeatureMaps,batchSize,...
    numAnchorBoxesPerFeatureMap,varargin)















%#codegen



    coder.inline('always')
    coder.allowpcode('plain')

    Z=coder.nullcopy(zeros(numAnchorBoxesForAllFeatureMaps,1,numChannels,batchSize,'like',varargin{1}));




    idxZ=1;
    for idx=1:numInputs
        permutedInput=permute(varargin{idx},[2,1,3,4]);
        reshapedInput=reshape(permutedInput,[numAnchorBoxesPerFeatureMap(idx),1,numChannels,batchSize]);
        Z(idxZ:idxZ+numAnchorBoxesPerFeatureMap(idx)-1,:,:,:)=reshapedInput;
        idxZ=idxZ+numAnchorBoxesPerFeatureMap(idx);
    end

end