%#codegen


function outputData=predictForRNN(obj,in,callerFunction,varargin)



    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    [miniBatchSize,sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,returnCategorical]=...
    coder.internal.DeepLearningNetwork.parseInputsCodegenPredictRNN(varargin{:});


    if(strcmpi(sequenceLengthMode,'longest')&&strcmpi(sequencePaddingDirection,'left')&&sequencePaddingValue==0)
        coder.internal.assert(~((strcmp(obj.DLTargetLib,'mkldnn')||strcmp(obj.DLTargetLib,'onednn'))),...
        'dlcoder_spkg:cnncodegen:unsupportedSequenceLengthAndPaddingValue',...
        'longest','left','0',...
        coder.const(obj.DLTargetLib));
    end

    [isCellInput,isImageInput,batchSize,miniBatchSize,numMiniBatches,remainder,outputFeatureSize,isImageOutput]=...
    coder.internal.DeepLearningNetwork.processInputSizeForPredictForRNN(obj,in,miniBatchSize,callerFunction,varargin);


    out=coder.internal.iohandling.rnn.OutputDataPreparer.prepareOutputForPredict(...
    in,outputFeatureSize,batchSize,isCellInput,isImageInput,isImageOutput,obj.HasSequenceOutput);








    if iscell(in)&&~coder.internal.isHomogeneousCell(in)
        coder.unroll();
    end
    for miniBatchIdx=1:numMiniBatches


        [miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=obj.prepareMinibatchForRNN(...
        in,obj.CodegenInputSizes{1}(1:3),miniBatchSize,...
        sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,...
        isCellInput,isImageInput,...
        miniBatchIdx,numMiniBatches,remainder,...
        callerFunction);


        obj.callSetSize(miniBatchSequenceLengthValue);


        outMiniBatch=obj.callPredictForRNN(miniBatch,...
        outputFeatureSize,miniBatchSequenceLengthValue,...
        obj.HasSequenceOutput,isCellInput,...
        isImageInput,isImageOutput);







        if(remainder>0)&&(miniBatchIdx==numMiniBatches)
            validSamples=remainder;
        else
            validSamples=miniBatchSize;
        end








        if~obj.HasSequenceOutput




            miniBatchOffset=miniBatchSize*(miniBatchIdx-1);
            if isCellInput
                if coder.isColumnMajor






                    permutedOutMiniBatch=permute(outMiniBatch,[3,2,1]);
                    out(miniBatchOffset+(1:validSamples),:)=permutedOutMiniBatch(1,1:validSamples,:);
                else

                    out(miniBatchOffset+(1:validSamples),:)=outMiniBatch(1,1:validSamples,:);
                end
            else
                if coder.isColumnMajor

                    outMiniBatchT=outMiniBatch';
                    out(miniBatchOffset+(1:validSamples),:)=outMiniBatchT(1:validSamples,:);
                else

                    out(miniBatchOffset+(1:validSamples),:)=outMiniBatch(1:validSamples,:);
                end
            end
        else
            if isCellInput

                for sampleIdx=1:validSamples
                    outIndex=miniBatchSize*(miniBatchIdx-1)+sampleIdx;
                    reshapedSample=obj.prepareRNNCellOutput(...
                    outMiniBatch,outputFeatureSize,sampleSequenceLengths,sequenceLengthMode,...
                    sequencePaddingDirection,sampleIdx,isImageOutput);
                    out{outIndex}=reshapedSample;
                end
            else



                if isImageOutput
                    if coder.isRowMajor




                        out=permute(outMiniBatch,[3,4,2,1]);
                    else


                        out=permute(outMiniBatch,[2,1,3,4]);
                    end
                else
                    if coder.isRowMajor


                        out=outMiniBatch';
                    else

                        out=outMiniBatch;
                    end
                end
            end
        end
    end


    if coder.const(returnCategorical)

        outputDataCell=obj.postProcessOutputToReturnCategorical({out});


        outputData=outputDataCell{1};
    else
        outputData=out;
    end
end
