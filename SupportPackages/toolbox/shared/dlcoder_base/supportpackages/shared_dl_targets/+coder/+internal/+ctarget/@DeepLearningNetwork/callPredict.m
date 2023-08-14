




















%#codegen



function outputs=callPredict(obj,inputsT,~,~)

    coder.allowpcode('plain');
    coder.inline('always');


    obj.checkNetworkIsSetUpForPredictCall();



    outputs=obj.callActivation(inputsT,obj.OutputLayerIndices,...
    ones(1,obj.NumOutputLayers),obj.DLTNetwork,obj.NetworkInfo,obj.NetworkName,...
    obj.CodegenInputSizes,obj.InputLayerIndices);
end
