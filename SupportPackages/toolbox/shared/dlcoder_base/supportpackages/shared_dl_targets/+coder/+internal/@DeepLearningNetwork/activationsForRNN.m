%#codegen


function out=activationsForRNN(obj,in,layerArg,callerFunction,varargin)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    [miniBatchSize,sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection]=coder.internal.DeepLearningNetwork.parseInputsCodegenActivationsRNN(varargin{:});

    [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,outputFeatureSize,layerIdx,portIdx,isSequenceOutput,isSequenceFolded,isImageOutput]=...
    coder.internal.DeepLearningNetwork.processInputSizeForActivationsForRNN(obj,in,layerArg,miniBatchSize,callerFunction,varargin);


    out=coder.internal.iohandling.rnn.OutputDataPreparer.prepareOutputForActivations(...
    in,outputFeatureSize,...
    batchSize,miniBatchSize,numMiniBatches,remainder,...
    sequenceLengthMode,isCellInput,isImageInput,isSequenceOutput,isSequenceFolded);


    miniBatchSequenceLengths=coder.nullcopy(ones(numMiniBatches,1));








    if iscell(in)&&~coder.internal.isHomogeneousCell(in)
        coder.unroll();
    end
    for miniBatchIdx=1:numMiniBatches


        [miniBatch,~,miniBatchSequenceLengthValue]=obj.prepareMinibatchForRNN(...
        in,obj.CodegenInputSizes{1}(1:3),miniBatchSize,...
        sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,...
        isCellInput,isImageInput,...
        miniBatchIdx,numMiniBatches,remainder,...
        callerFunction);
        miniBatchSequenceLengths(miniBatchIdx)=miniBatchSequenceLengthValue;


        obj.callSetSize(miniBatchSequenceLengthValue);


        outMiniBatch=obj.callActivationsForRNN(miniBatch,int32(layerIdx),int32(portIdx),...
        outputFeatureSize,miniBatchSequenceLengthValue,...
        isSequenceOutput,isSequenceFolded,...
        isCellInput,...
        isImageInput,isImageOutput);







        if(remainder>0)&&(miniBatchIdx==numMiniBatches)
            validSamples=remainder;
        else
            validSamples=miniBatchSize;
        end








        if coder.const(isSequenceOutput)
            if coder.const(isImageOutput)
                for sampleIdx=1:validSamples
                    outIndex=miniBatchSize*(miniBatchIdx-1)+sampleIdx;


                    outSample=obj.prepareImageOutSampleForActivations(...
                    outMiniBatch,sampleIdx,isCellInput);

                    out{outIndex}=outSample;
                end
            else

                for sampleIdx=1:validSamples
                    outIndex=miniBatchSize*(miniBatchIdx-1)+sampleIdx;


                    outSample=obj.prepareVectorOutSampleForActivations(...
                    outMiniBatch,sampleIdx,isCellInput);

                    out{outIndex}=outSample;
                end
            end
        else

            if coder.const(isImageOutput)




                assert(coder.const(isSequenceFolded));

                coder.unroll();
                for sampleIdx=1:validSamples













                    outSample=obj.prepareImageOutSampleForActivations(outMiniBatch,sampleIdx,isCellInput);







                    currentBatchOffset=sum(miniBatchSequenceLengths(1:(miniBatchIdx-1)))*miniBatchSize;

                    for timestep=1:miniBatchSequenceLengthValue
                        currentSampleIdx=currentBatchOffset+(timestep-1)*validSamples+sampleIdx;
                        out(:,:,:,currentSampleIdx)=...
                        outSample(:,:,:,timestep);
                    end
                end
            else

                if coder.const(isSequenceFolded)
                    for sampleIdx=1:validSamples













                        outSample=obj.prepareVectorOutSampleForActivations(outMiniBatch,sampleIdx,isCellInput);







                        currentBatchOffset=sum(miniBatchSequenceLengths(1:(miniBatchIdx-1)))*miniBatchSize;

                        for timestep=1:miniBatchSequenceLengthValue
                            currentSampleIdx=currentBatchOffset+(timestep-1)*validSamples+sampleIdx;
                            out(:,currentSampleIdx)=...
                            outSample(:,timestep);
                        end
                    end
                else

                    for sampleIdx=1:validSamples
                        outIdx=miniBatchSize*(miniBatchIdx-1)+sampleIdx;

                        outSample=obj.prepareVectorOutSampleForActivations(outMiniBatch,sampleIdx,isCellInput);

                        out(:,outIdx)=outSample;
                    end
                end
            end
        end
    end
end
