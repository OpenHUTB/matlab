%#codegen



function[isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,...
    outputFeatureSize,layerIdx,portIdx,isSequenceOutput,isSequenceFolded,isImageOutput]=...
    processInputSizeForActivationsForRNN(obj,in,layerArg,miniBatchSize,callerFunction,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder]=...
    coder.internal.DeepLearningNetwork.setInputSizeForRNN(obj,in,miniBatchSize,callerFunction,varargin);



    layerArg=coder.internal.DeepLearningNetworkUtils.validateLayerArg(layerArg);


    if coder.const(isImageInput)
        inSize=obj.CodegenInputSizes;
    else




        inSize={obj.CodegenInputSizes{1}(3:4)};
    end

    coder.extrinsic('coder.internal.DeepLearningNetworkUtils.getIOPropsForLayer');
    [outputFeatureSize,layerIdx,portIdx,isSequenceOutput,isSequenceFolded]=coder.const(...
    @coder.internal.DeepLearningNetworkUtils.getIOPropsForLayer,...
    obj.DLTNetwork,...
    layerArg,...
    inSize,...
    obj.DLTargetLib);

    isImageOutput=coder.const(numel(outputFeatureSize)==3);
end
