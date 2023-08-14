

















%#codegen


function outputs=callPredict(obj,inputsT,outsizes,numOutputs)

    coder.allowpcode('plain');
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetwork.prepareInputSizesForCeval');
    coder.internal.prefer_const(outsizes);
    out_type='single';

    new_outsizes=cell(numOutputs,1);


    outputs=cell(numOutputs,1);


    for outIdx=1:numOutputs
        isImageInput=numel(outsizes{outIdx})==4;
        if isImageInput
            new_outsizes{outIdx}=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getCevalImageOutputSize(...
            outsizes{outIdx},obj.DLTargetLib);
        else

            assert(numel(outsizes{outIdx})==2);
            new_outsizes{outIdx}=...
            coder.internal.iohandling.cnn.OutputDataPreparer.getCevalVectorOutputSize(...
            outsizes{outIdx},obj.DLTargetLib);
        end


        outputs{outIdx}=coder.nullcopy(zeros(new_outsizes{outIdx},out_type));
    end

    coder.ceval('-layout:any',obj.predictAnchorName,obj.NetworkInfo,coder.const(obj.getMiniBatchSize));


    coder.ceval('-preservearraydims','-layout:any',obj.predictFcnName,...
    coder.wref(obj.anchor),...
    coder.internal.valuelistfun(@coder.rref,inputsT,'gpu'),...
    coder.internal.valuelistfun(@coder.wref,outputs,'gpu'));

    obj.callPredictForCustomLayers(1);

end
