

















%#codegen



function outputs=callPredict(obj,inputsT,...
    outsizes,isInputSequenceVarsized,outputFormats,numOutputsRequested,...
    sortedOutputLayerIndices,sortedOutputPortIndices)

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(outsizes,isInputSequenceVarsized,outputFormats,...
    numOutputsRequested,sortedOutputLayerIndices,sortedOutputPortIndices);


    outputs=allocateOutputMemory(obj,numOutputsRequested,outsizes,outputFormats,isInputSequenceVarsized);

    coder.ceval('-layout:any',obj.PredictAnchorName,obj.NetworkInfo,coder.const(obj.BatchSize));


    coder.ceval('-preservearraydims','-layout:any',obj.PredictFcnName,...
    coder.wref(obj.anchor),...
    coder.const(numOutputsRequested),...
    coder.internal.valuelistfun(@coder.const,sortedOutputLayerIndices),...
    coder.internal.valuelistfun(@coder.const,sortedOutputPortIndices),...
    coder.internal.valuelistfun(@coder.rref,inputsT,'gpu'),...
    coder.internal.valuelistfun(@coder.wref,outputs,'gpu'));


    obj.callPredictForCustomLayers();

end
