
function[numAnchorBoxesForAllFeatureMaps,b,numAnchorBoxesPerFeatureMap]=computeSSDLayerParameters(numInputs,numChannels,varargin)




%#codegen

    coder.allowpcode('plain')

    numAnchorBoxesForAllFeatureMaps=0;
    h=coder.nullcopy(zeros(1,numInputs));
    w=coder.nullcopy(zeros(1,numInputs));
    c=coder.nullcopy(zeros(1,numInputs));
    numBoxesPerGrid=coder.nullcopy(zeros(1,numInputs));
    numAnchorBoxesPerFeatureMap=coder.nullcopy(zeros(1,numInputs));
    for idx=1:numInputs
        [h(idx),w(idx),c(idx),b]=size(varargin{idx});
        numBoxesPerGrid(idx)=c(idx)/numChannels;
        numAnchorBoxesPerFeatureMap(idx)=h(idx)*w(idx)*numBoxesPerGrid(idx);
        numAnchorBoxesForAllFeatureMaps=numAnchorBoxesForAllFeatureMaps+numAnchorBoxesPerFeatureMap(idx);
    end
end
