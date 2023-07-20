





















%#codegen


function out=callActivationsForRNN(obj,minibatch,layerIdx,portIdx,...
    outputFeatureSize,miniBatchSequenceLengthValue,...
    isSequenceOutput,isSequenceFolded,...
    isCellInput,...
    isImageInput,isImageOutput)

    coder.allowpcode('plain');
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetwork.prepareInputSizesForCeval');



    out=coder.internal.iohandling.rnn.OutputDataPreparer.getOutput(...
    obj.DLTargetLib,outputFeatureSize,isSequenceOutput,isSequenceFolded,isCellInput,isImageInput,isImageOutput,obj.getMiniBatchSize,miniBatchSequenceLengthValue,minibatch);


    coder.ceval('-layout:any',obj.activationAnchorName,obj.NetworkInfo,coder.const(obj.getMiniBatchSize));

    coder.ceval('-preservearraydims','-layout:any',obj.activationFcnName,...
    coder.wref(obj.anchor),...
    coder.const(layerIdx),...
    coder.const(portIdx-1),...
    coder.rref(minibatch,'gpu'),...
    coder.ref(out,'gpu'));

    obj.callPredictForCustomLayers(miniBatchSequenceLengthValue);
end
