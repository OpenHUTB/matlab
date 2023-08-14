function validateLearnables(expectedLearnablesSizes,learnables)











%#codegen


    coder.allowpcode('plain');

    coder.extrinsic('coder.internal.coderNetworkUtils.prepareSizeForErrorMessage');
    coder.internal.prefer_const(expectedLearnablesSizes);

    learnableLayerNames=fieldnames(learnables);
    numLearnableLayers=numel(learnableLayerNames);
    numExpectedLearnables=numel(expectedLearnablesSizes);

    learnableCount=0;
    for iLearnableLayer=1:numLearnableLayers
        layerLearnables=learnables.(learnableLayerNames{iLearnableLayer});
        layerLearnableNames=fieldnames(layerLearnables);
        numLayerLearnables=numel(layerLearnableNames);
        for iLearnable=1:numLayerLearnables
            learnableCount=learnableCount+1;


            coder.internal.assert(numExpectedLearnables>=learnableCount,'dlcoder_spkg:cnncodegen:IncorrectNumLearnables');

            expectedSize=expectedLearnablesSizes{learnableCount};
            expectedSizeString=coder.const(@coder.internal.coderNetworkUtils.prepareSizeForErrorMessage,expectedSize);

            learnableValue=layerLearnables.(layerLearnableNames{iLearnable});
            actualSize=size(learnableValue);

            coder.internal.assert(coder.internal.isConst(actualSize),'dlcoder_spkg:cnncodegen:VariableLearnableSize',...
            learnableLayerNames{iLearnableLayer},layerLearnableNames{iLearnable},expectedSizeString);

            if~isequal(actualSize,expectedSize)
                actualSizeString=coder.const(@coder.internal.coderNetworkUtils.prepareSizeForErrorMessage,actualSize);
                coder.internal.assert(false,'dlcoder_spkg:cnncodegen:InvalidLearnableSize',learnableLayerNames{iLearnableLayer},...
                layerLearnableNames{iLearnable},expectedSizeString,actualSizeString);
            end
            coder.internal.errorIf(~isa(learnableValue,'single'),'dlcoder_spkg:cnncodegen:InvalidLearnableType',...
            learnableLayerNames{iLearnableLayer},layerLearnableNames{iLearnable},class(learnableValue));
        end
    end


    coder.internal.assert(numExpectedLearnables==learnableCount,'dlcoder_spkg:cnncodegen:IncorrectNumLearnables');

end
