




















%#codegen


function out=callPredictForRNN(obj,minibatch,...
    outputFeatureSize,miniBatchSequenceLengthValue,...
    isSequenceOutput,isCellInput,...
    isImageInput,isImageOutput)

    coder.allowpcode('plain');
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetwork.prepareInputSizesForCeval');



    isSequenceFolded=false;
    out=coder.internal.iohandling.rnn.OutputDataPreparer.getOutput(obj.DLTargetLib,...
    outputFeatureSize,isSequenceOutput,isSequenceFolded,isCellInput,isImageInput,isImageOutput,obj.getMiniBatchSize,miniBatchSequenceLengthValue,minibatch);

    coder.ceval('-layout:any',obj.predictAnchorName,obj.NetworkInfo,coder.const(obj.getMiniBatchSize));

    coder.ceval('-preservearraydims','-layout:any',obj.predictFcnName,...
    coder.wref(obj.anchor),...
    coder.rref(minibatch,'gpu'),...
    coder.ref(out,'gpu'));

    obj.callPredictForCustomLayers(miniBatchSequenceLengthValue);
end
