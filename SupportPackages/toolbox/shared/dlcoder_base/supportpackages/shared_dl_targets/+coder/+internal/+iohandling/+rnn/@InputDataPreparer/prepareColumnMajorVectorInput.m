%#codegen









function[miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=...
    prepareColumnMajorVectorInput(indata,inputSize,miniBatchSize,...
    sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,...
    isCellInput,...
    miniBatchIdx,numMiniBatches,remainder,permutationDims)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    featureDim=inputSize(3);
    sequenceDimensionIndex=2;


    if isCellInput
        sampleSequenceLengths=coder.nullcopy(zeros(miniBatchSize,1));

        miniBatchSequenceLengthValue=...
        coder.internal.DeepLearningNetworkUtils.getSequenceLengthRNNCellInput(...
        indata,miniBatchSize,miniBatchIdx,sequenceLengthMode,numMiniBatches,remainder,false);




        miniBatch=coder.nullcopy(zeros(featureDim,miniBatchSize,miniBatchSequenceLengthValue,'like',indata{1}));







        if(remainder>0)&&(miniBatchIdx==numMiniBatches)
            validSamples=remainder;
        else
            validSamples=miniBatchSize;
        end

        if coder.const(strcmp(sequenceLengthMode,'longest'))
            for sampleIdx=1:validSamples
                sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};



                outSequenceLength=size(sample,sequenceDimensionIndex);


                sampleSequenceLengths(sampleIdx)=outSequenceLength;





                if strcmp(coder.const(sequencePaddingDirection),'right')
                    miniBatch(:,sampleIdx,1:outSequenceLength)=sample;
                    miniBatch(:,sampleIdx,(outSequenceLength+1):end)=sequencePaddingValue;
                else

                    miniBatch(:,sampleIdx,(1-outSequenceLength:0)+end)=sample;
                    miniBatch(:,sampleIdx,1:(end-outSequenceLength))=sequencePaddingValue;
                end
            end
        else
            for sampleIdx=1:validSamples
                sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};




                sampleSequenceLengths(sampleIdx)=miniBatchSequenceLengthValue;


                if strcmp(coder.const(sequencePaddingDirection),'right')
                    miniBatch(:,sampleIdx,:)=sample(:,1:miniBatchSequenceLengthValue);
                else
                    miniBatch(:,sampleIdx,:)=sample(:,(1-miniBatchSequenceLengthValue:0)+end);
                end
            end
        end
    else


        miniBatch=coder.internal.DeepLearningNetworkUtils.permuteData(indata,permutationDims);

        miniBatchSequenceLengthValue=size(indata,sequenceDimensionIndex);


        sampleSequenceLengths=miniBatchSequenceLengthValue;
    end
end
