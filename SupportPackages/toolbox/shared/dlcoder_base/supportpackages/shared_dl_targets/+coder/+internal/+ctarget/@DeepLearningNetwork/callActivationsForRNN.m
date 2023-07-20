





















%#codegen



function outMiniBatch=callActivationsForRNN(obj,miniBatch,layerIdx,portIdx,~,~,~,~,~,~,~)

    coder.allowpcode('plain');
    coder.inline('always');


    obj.checkNetworkIsSetUpForPredictCall();


    outMiniBatchC=obj.callActivation({miniBatch},layerIdx,portIdx,...
    obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,obj.CodegenInputSizes,...
    obj.InputLayerIndices);

    outMiniBatch=outMiniBatchC{:};

end
