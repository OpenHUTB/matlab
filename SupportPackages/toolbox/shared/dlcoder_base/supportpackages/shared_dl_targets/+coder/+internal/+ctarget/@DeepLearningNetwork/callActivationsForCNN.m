












%#codegen


function outputs=callActivationsForCNN(obj,inputsT,layerIdx,portIdx,~)
    coder.allowpcode('plain');
    coder.inline('always');


    obj.checkNetworkIsSetUpForPredictCall();


    outputs=obj.callActivation(inputsT,layerIdx,...
    portIdx,obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,...
    obj.CodegenInputSizes,obj.InputLayerIndices);
end
