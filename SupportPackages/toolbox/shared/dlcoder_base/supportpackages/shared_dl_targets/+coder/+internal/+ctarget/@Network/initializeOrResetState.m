function obj=initializeOrResetState(obj,codegenInputSizes)












%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(codegenInputSizes);

    [statefulLayers,statefulLayerIndices]=coder.const(@feval,'getStatefulLayers',obj.DLCustomCoderNetwork);
    numStatefulLayers=coder.const(@feval,'getNumStatefulLayers',obj.DLCustomCoderNetwork);
    obj.NetworkState=cell(1,numStatefulLayers);


    miniBatchDimension=4;
    miniBatchSize=coder.const(codegenInputSizes{1}(miniBatchDimension));



    for iLayer=coder.unroll(1:numStatefulLayers)
        layerObj=coder.const(statefulLayers(iLayer));
        statefulIdx=statefulLayerIndices(iLayer);

        obj.NetworkState{statefulIdx}=cell(1,layerObj.NumStates);


        for iState=coder.unroll(1:layerObj.NumStates)

            obj.NetworkState{statefulIdx}{iState}=repmat(layerObj.State{iState},1,miniBatchSize);
        end
    end

end