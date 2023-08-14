%#codegen












function checkInputSize(inputDataCell,net_insizes,isPredict)



    coder.allowpcode('plain');

    numInputs=numel(inputDataCell);
    coder.unroll()
    for i=1:numInputs

        inputData=inputDataCell{i};
        networkInputSize=coder.const(net_insizes{i});

        isImageInput=numel(networkInputSize)==3;
        if coder.const(isImageInput)




            inputHeight=size(inputData,1);
            inputWidth=size(inputData,2);
            inputChannels=size(inputData,3);

            inputLayerHeight=networkInputSize(1);
            inputLayerWidth=networkInputSize(2);
            inputLayerChannels=networkInputSize(3);

            if(~isPredict)



                coder.internal.assert(...
                all(coder.const(@ge,[inputHeight,inputWidth],[inputLayerHeight,inputLayerWidth]))&&...
                (coder.const(@isequal,inputChannels,inputLayerChannels)),...
                'dlcoder_spkg:cnncodegen:invalid_inputsize_activations',...
                coder.const(@int2str,inputLayerHeight),...
                coder.const(@int2str,inputLayerWidth),...
                coder.const(@int2str,inputLayerChannels)...
                );
            else



                coder.internal.assert(...
                coder.const(@isequal,[inputHeight,inputWidth,inputChannels],[inputLayerHeight,inputLayerWidth,inputLayerChannels]),...
                'dlcoder_spkg:cnncodegen:invalid_inputsize',...
                coder.const(@int2str,inputLayerHeight),...
                coder.const(@int2str,inputLayerWidth),...
                coder.const(@int2str,inputLayerChannels)...
                );
            end
        else
            coder.internal.assert(coder.const(@numel,networkInputSize)==1,'dlcoder_spkg:cnncodegen:DLCoderInternalError');





            inputChannels=size(inputData,2);
            inputLayerChannels=networkInputSize(1);

            if coder.const(isPredict)
                inferenceFunction='predict';
            else
                inferenceFunction='activations';
            end

            coder.internal.assert(...
            coder.const(@isequal,inputChannels,inputLayerChannels),...
            'dlcoder_spkg:cnncodegen:invalid_inputsize_featureInputLayer',...
            coder.const(@int2str,inputLayerChannels),...
            coder.const(inferenceFunction)...
            );
        end
    end
end
