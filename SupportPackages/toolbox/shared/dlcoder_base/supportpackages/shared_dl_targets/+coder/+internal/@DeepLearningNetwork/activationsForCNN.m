%#codegen


function out=activationsForCNN(obj,numInputs,dataInputsSingle,layerArg,inputFeatureSizes,batchSize,miniBatchSize)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;



    miniBatchSize=coder.const(min(miniBatchSize,batchSize));


    coder.internal.assert(coder.internal.isConst(miniBatchSize),...
    'dlcoder_spkg:cnncodegen:VariableMiniBatchSize',...
    'activations');

    remainder=coder.const(mod(batchSize,miniBatchSize));
    isPadded=remainder>0;


    paddedBatchSize=coder.const(ceil(batchSize/miniBatchSize)*miniBatchSize);


    indata=cell(numInputs,1);
    isImageInput=coder.nullcopy(zeros(numInputs,1));
    for i=1:numInputs
        inputLayerSize=obj.NetworkInputSizes{i};
        isImageInput(i)=numel(inputLayerSize)==3;
        indata{i}=coder.internal.iohandling.cnn.InputDataPreparer.batchPadInputData(...
        dataInputsSingle{i},batchSize,paddedBatchSize,isPadded,isImageInput(i));
    end


    numMiniBatches=coder.const(paddedBatchSize/miniBatchSize);


    oldInputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
    newInputSizes=cell(numInputs,1);
    for i=1:numInputs
        newInputSizes{i}=[inputFeatureSizes{i}...
        ,miniBatchSize];



        if coder.const(~isempty(oldInputSizes))
            coder.internal.iohandling.cnn.InputDataPreparer.checkInputsForVaryingSize(...
            oldInputSizes{i},newInputSizes{i},'activations');
        end
    end

    obj.CodegenInputSizes=newInputSizes;


    calledFromPredict=0;
    coder.internal.iohandling.cnn.InputDataPreparer.checkInputSize(...
    indata,...
    obj.NetworkInputSizes,...
    calledFromPredict);



    newBatchSize=coder.const(batchSize);

    oldBatchSize=coder.internal.getprop_if_defined(obj.BatchSize);
    if~isempty(oldBatchSize)

        coder.internal.assert(coder.const(@isequal,oldBatchSize,newBatchSize),...
        'dlcoder_spkg:cnncodegen:VaryingBatchSize',...
        oldBatchSize,...
        newBatchSize,...
'activations'...
        );
    end

    obj.BatchSize=newBatchSize;


    obj.setAnchor();


    obj.setNetworkInfo();





    if coder.const(~isequal(newInputSizes,oldInputSizes)||~isequal(newBatchSize,oldBatchSize))
        obj.validate();
    end




    obj.setCustomLayerProperties();



    [outputSize,layerIdx,portIdx]=iGetIOPropsForLayer(obj,...
    layerArg,...
    obj.DLTargetLib);

    miniBatchOutSize=[outputSize,miniBatchSize];
    outsize=[outputSize,batchSize];
    paddedOutsize=[outputSize,paddedBatchSize];



    if isPadded
        outdata=coder.nullcopy(zeros(paddedOutsize,'single'));
    else
        outdata=coder.nullcopy(zeros(outsize,'single'));
    end

    for miniBatchIdx=1:numMiniBatches


        inMiniBatchGroup=cell(numInputs,1);
        for inputIdx=1:numInputs
            inMiniBatchGroup{inputIdx}=iPrepareInputMinibatch(...
            indata,inputIdx,miniBatchIdx,miniBatchSize,isImageInput,obj.DLTargetLib);
        end

        outMiniBatch=obj.callActivationsForCNN(inMiniBatchGroup,int32(layerIdx),int32(portIdx),miniBatchOutSize);
        isImageOutput=numel(miniBatchOutSize)==4;
        if iscell(outMiniBatch)

            outMiniBatchT=iPrepareOutputMinibatch(obj,outMiniBatch{:},isImageOutput,obj.DLTargetLib);
        else
            outMiniBatchT=iPrepareOutputMinibatch(obj,outMiniBatch,isImageOutput,obj.DLTargetLib);
        end


        if isImageOutput
            outdata(:,:,:,miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize))=outMiniBatchT;
        else
            assert(numel(miniBatchOutSize)==2);

            outdata(:,miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize))=outMiniBatchT;
        end
    end

    if isPadded
        if isImageOutput
            out=outdata(:,:,:,1:batchSize);
        else
            out=outdata(:,1:batchSize);
        end
    else
        out=outdata;
    end

end


function[outSize,layerIdx,portId]=iGetIOPropsForLayer(obj,layerArg,targetlib)
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetworkUtils.getIOPropsForLayer');






    [outSize,layerIdx,portId]=coder.const(...
    @coder.internal.DeepLearningNetworkUtils.getIOPropsForLayer,...
    obj.DLTNetwork,...
    layerArg,...
    obj.CodegenInputSizes,...
    targetlib);

end


function inMiniBatch=iPrepareInputMinibatch(indata,inputIdx,miniBatchIdx,miniBatchSize,isImageInput,targetLib)
    coder.inline('always');

    if isImageInput(inputIdx)
        inMiniBatch=indata{inputIdx}(:,:,:,miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize));
        inMiniBatch=coder.internal.iohandling.cnn.InputDataPreparer.permuteImageInput(inMiniBatch,targetLib);
    else

        miniBatch=indata{inputIdx}(miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize),:);
        inMiniBatch=coder.internal.coderNetworkUtils.permuteCNNVectorData(miniBatch,targetLib);
    end
end

function outMiniBatch=iPrepareOutputMinibatch(obj,miniBatch,isImageOutput,targetLib)
    coder.inline('always');

    if isImageOutput
        outMiniBatch=coder.internal.iohandling.cnn.OutputDataPreparer.permuteImageOutput(miniBatch,targetLib);
    else



        if~coder.const(@feval,'coder.internal.coderNetworkUtils.hasPermuteForTarget',targetLib)

            outMiniBatch=obj.prepareVectorData(miniBatch);
        else
            if coder.isColumnMajor


                outMiniBatch=miniBatch;
            else

                outMiniBatch=miniBatch';
            end
        end
    end
end
