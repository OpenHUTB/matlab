%#codegen





function[miniBatchSize,numMiniBatches,remainder]=getMiniBatchInfo(miniBatchSize,batchSize,callerFunction)
    coder.allowpcode('plain');



    miniBatchSize=coder.const(min(miniBatchSize,batchSize));

    if coder.const(strcmp(callerFunction,'predictAndUpdateState')||strcmp(callerFunction,'classifyAndUpdateState'))
        coder.internal.assert(coder.const(miniBatchSize==batchSize),...
        'dlcoder_spkg:cnncodegen:BadMiniBatchSizeForStateful',...
        callerFunction,miniBatchSize,batchSize);
    end


    coder.internal.assert(coder.internal.isConst(miniBatchSize),...
    'dlcoder_spkg:cnncodegen:VariableMiniBatchSize',...
    'predict');

    remainder=mod(batchSize,miniBatchSize);


    numMiniBatches=coder.const(ceil(batchSize/miniBatchSize));
end
