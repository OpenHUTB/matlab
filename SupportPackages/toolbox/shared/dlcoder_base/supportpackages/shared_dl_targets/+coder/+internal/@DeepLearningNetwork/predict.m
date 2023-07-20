%#codegen





function varargout=predict(obj,varargin)



    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    coder.inline('never');

    coder.gpu.internal.kernelfunImpl(false);


    minArgs=1;
    maxArgs=obj.NumOutputLayers;
    nargoutchk(minArgs,maxArgs);


    minArgsIn=coder.const(obj.NumInputLayers);
    iValidateNumInputs(minArgsIn,(nargin-1));


    numOutputs=coder.const(nargout);


    if obj.IsRNN


        in=varargin{1};
        nvps={varargin{2:end}};

        varargout{1}=obj.predictForRNN(in,'predict',nvps{:});
    else

        numInputs=coder.const(obj.NumInputLayers);


        [miniBatchSize,returnCategorical]=coder.internal.DeepLearningNetwork.parseInputsCodegenPredictCNN(varargin{numInputs+1:end});

        dataInputs={varargin{1:numInputs}};
        dataInputsSingle=cell(numInputs,1);



        inputFeatureSizes=cell(numInputs,1);

        for i=1:numInputs

            [height,width,channels,batchSize]=...
            coder.internal.iohandling.cnn.InputDataPreparer.parseInputSize(dataInputs{i},obj.NetworkInputSizes{i},'predict',obj.DLTargetLib);

            inputFeatureSizes{i}=[height,width,channels];


            coder.internal.coderNetworkUtils.checkAndWarnForHalfInput(class(dataInputs{i}),obj.DataType,'predict');


            dataInputsSingle{i}=single(dataInputs{i});
        end



        miniBatchSize=coder.const(min(miniBatchSize,batchSize));

        remainder=coder.const(mod(batchSize,miniBatchSize));
        isPadded=remainder>0;


        paddedBatchSize=coder.const(iGetPaddedBatchSize(batchSize,miniBatchSize));


        indata=cell(numInputs,1);
        isImageInput=cell(numInputs,1);
        for i=1:numInputs
            inputLayerSize=obj.NetworkInputSizes{i};
            isImageInput{i}=numel(inputLayerSize)==3;
            indata{i}=coder.internal.iohandling.cnn.InputDataPreparer.batchPadInputData(...
            dataInputsSingle{i},batchSize,paddedBatchSize,isPadded,isImageInput{i});
        end


        oldInputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);
        newInputSizes=cell(numInputs,1);
        for i=1:numInputs
            newInputSizes{i}=[inputFeatureSizes{i}...
            ,miniBatchSize];



            if coder.const(~isempty(oldInputSizes))
                coder.internal.iohandling.cnn.InputDataPreparer.checkInputsForVaryingSize(...
                oldInputSizes{i},newInputSizes{i},'predict');
            end
        end

        obj.CodegenInputSizes=newInputSizes;



        calledFromPredict=1;
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
'predict'...
            );
        end

        obj.BatchSize=newBatchSize;


        obj.setAnchor();



        obj.setNetworkInfo();





        if~isequal(newInputSizes,oldInputSizes)||~isequal(newBatchSize,oldBatchSize)
            obj.validate();
        end




        obj.setCustomLayerProperties();


        [miniBatchOutsizes,outsizes,paddedOutsizes]=coder.const(@iGetNetworkIOSizes,obj,...
        miniBatchSize,batchSize,paddedBatchSize);



        outdata=iAllocateOutputData(paddedOutsizes,outsizes,isPadded,numOutputs);

        miniBatchSize=coder.const(obj.getMiniBatchSize);


        numMiniBatches=coder.const(paddedBatchSize/miniBatchSize);


        for miniBatchIdx=1:numMiniBatches



            inMiniBatchGroup=cell(numInputs,1);

            for inputIdx=1:numInputs
                inMiniBatchGroup{inputIdx}=iPrepareInputMinibatch(...
                indata,inputIdx,miniBatchIdx,miniBatchSize,isImageInput,obj.DLTargetLib);
            end

            outMiniBatchGroup=obj.callPredict(inMiniBatchGroup,coder.const(miniBatchOutsizes),numOutputs);



            coder.unroll();
            for outputIdx=1:numOutputs

                miniBatchOutsize=miniBatchOutsizes{outputIdx};
                isImageOutput=numel(miniBatchOutsize)==4;

                outMiniBatch=iPrepareOutputMinibatch(obj,...
                outMiniBatchGroup,coder.const(outputIdx),isImageOutput,obj.DLTargetLib);


                if isImageOutput
                    outdata{outputIdx}(:,:,:,miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize))=outMiniBatch;
                else
                    assert(numel(miniBatchOutsize)==2);
                    outdata{outputIdx}(miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize),:)=outMiniBatch;
                end
            end

        end



        unpaddedScores=cell(1,numOutputs);
        coder.unroll();
        for outputIdx=1:numOutputs
            isImageOutput=numel(outsizes{outputIdx})==4;

            if coder.const(isPadded)
                if coder.const(isImageOutput)
                    unpaddedScores{outputIdx}=outdata{outputIdx}(:,:,:,1:batchSize);
                else
                    numDims=coder.const(numel(outsizes{outputIdx}));
                    coder.internal.assert(numDims==2,'dlcoder_spkg:cnncodegen:DLCoderInternalError');
                    unpaddedScores{outputIdx}=outdata{outputIdx}(1:batchSize,:);
                end
            else
                unpaddedScores{outputIdx}=outdata{outputIdx};
            end

        end


        if coder.const(returnCategorical)

            varargout=obj.postProcessOutputToReturnCategorical(unpaddedScores);
        else
            varargout=unpaddedScores;
        end

    end
end



function paddedBatchSize=iGetPaddedBatchSize(batchSize,miniBatchSize)

    coder.inline('always');
    paddedBatchSize=ceil(batchSize/miniBatchSize)*miniBatchSize;

end


function[outMiniBatchSizes,outBatchSizes,outPaddedBatchSizes]=iGetNetworkIOSizes(obj,miniBatchSize,batchSize,paddedBatchSize)
    coder.inline('always');
    coder.extrinsic('coder.internal.DeepLearningNetwork.getIOProps');

    [outMiniBatchSizes,outBatchSizes,outPaddedBatchSizes]=coder.const(...
    @coder.internal.DeepLearningNetwork.getIOProps,...
    obj.DLTNetwork,...
    obj.NetworkInputSizes,...
    miniBatchSize,...
    batchSize,...
    paddedBatchSize);

end




function outdata=iAllocateOutputData(paddedOutsizes,outsizes,isPadded,numNetOutputs)
    coder.inline('always');
    outdata=cell(numNetOutputs,1);
    if isPadded
        for i=1:numNetOutputs
            outdata{i}=coder.nullcopy(zeros(coder.const(paddedOutsizes{i}),'single'));
        end

    else
        for i=1:numNetOutputs
            outdata{i}=coder.nullcopy(zeros(coder.const(outsizes{i}),'single'));
        end
    end

end


function iValidateNumInputs(expectedNumInputs,actualNumberOfInputs)
    coder.inline('always');

    coder.internal.assert(actualNumberOfInputs>=expectedNumInputs,'dlcoder_spkg:cnncodegen:InsufficientInputs',expectedNumInputs);
end


function inMiniBatch=iPrepareInputMinibatch(indata,inputIdx,miniBatchIdx,miniBatchSize,isImageInput,targetLib)
    coder.inline('always');

    if isImageInput{inputIdx}
        inMiniBatch=indata{inputIdx}(:,:,:,miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize));
        inMiniBatch=coder.internal.iohandling.cnn.InputDataPreparer.permuteImageInput(inMiniBatch,targetLib);
    else

        miniBatch=indata{inputIdx}(miniBatchSize*(miniBatchIdx-1)+(1:miniBatchSize),:);
        inMiniBatch=coder.internal.coderNetworkUtils.permuteCNNVectorData(miniBatch,targetLib);
    end
end

function outMiniBatch=iPrepareOutputMinibatch(obj,outMiniBatchGroup,outputIdx,isImageOutput,targetLib)
    coder.inline('always');

    miniBatch=outMiniBatchGroup{outputIdx};
    if isImageOutput
        outMiniBatch=coder.internal.iohandling.cnn.OutputDataPreparer.permuteImageOutput(miniBatch,targetLib);
    else

        outMiniBatch=coder.internal.coderNetworkUtils.permuteCNNVectorData(obj.prepareVectorData(miniBatch),targetLib);
    end
end
