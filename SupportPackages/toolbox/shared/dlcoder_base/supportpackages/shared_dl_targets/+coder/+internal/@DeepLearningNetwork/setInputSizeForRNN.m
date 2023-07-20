%#codegen










function[isCellInput,isImageInput,...
    batchSize,miniBatchSize,numMiniBatches,remainder]=setInputSizeForRNN(obj,in,miniBatchSize,callerFunction,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    isCellInput=coder.const(isa(in,'cell'));






    [height,width,channels,batchSize]=...
    coder.internal.iohandling.rnn.InputDataPreparer.parseInputSize(in,obj.NetworkInputSizes{1},isCellInput);
    coder.const(height);
    coder.const(width);
    coder.const(channels);
    coder.const(batchSize);


    coder.extrinsic('coder.internal.iohandling.rnn.InputDataPreparer.checkInputSize');
    isImageInput=coder.const(numel(obj.NetworkInputSizes{1})==3);
    coder.const(...
    @coder.internal.iohandling.rnn.InputDataPreparer.checkInputSize,...
    [height,width,channels],...
    obj.NetworkInputSizes{1},...
    callerFunction,...
    isImageInput);


    [miniBatchSize,numMiniBatches,remainder]=...
    coder.internal.DeepLearningNetworkUtils.getMiniBatchInfo(miniBatchSize,batchSize,callerFunction);






    coder.internal.DeepLearningNetwork.setNetworkSizes(obj,height,width,channels,miniBatchSize,batchSize,callerFunction)
end

