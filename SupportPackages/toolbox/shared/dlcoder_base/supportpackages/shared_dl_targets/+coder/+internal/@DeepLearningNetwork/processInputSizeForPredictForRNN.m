%#codegen



function[isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,outputFeatureSize,isImageOutput]=...
    processInputSizeForPredictForRNN(obj,in,miniBatchSize,callerFunction,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder]=...
    coder.internal.DeepLearningNetwork.setInputSizeForRNN(obj,in,miniBatchSize,callerFunction,varargin);



    coder.extrinsic('coder.internal.DeepLearningNetwork.getIOPropsForRNN');
    [outputFeatureSize,isImageOutput]=coder.const(...
    @coder.internal.DeepLearningNetwork.getIOPropsForRNN,...
    obj.DLTNetwork,...
    obj.HasSequenceOutput,...
    obj.NetworkInfo);
end
