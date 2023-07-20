%#codegen









function[miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=...
    prepareRowMajorVectorInput(indata,inputSize,miniBatchSize,...
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




        miniBatch=sequencePaddingValue*ones(miniBatchSequenceLengthValue,miniBatchSize,featureDim,'like',indata{1});







        if(remainder>0)&&(miniBatchIdx==numMiniBatches)
            validSamples=remainder;
        else
            validSamples=miniBatchSize;
        end

        if coder.const(strcmp(sequenceLengthMode,'longest'))
            for sampleIdx=1:validSamples
                sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};
                outSequenceLength=size(sample,2);


                sampleSequenceLengths(sampleIdx)=outSequenceLength;




                if strcmp(coder.const(sequencePaddingDirection),'right')
                    miniBatch(1:outSequenceLength,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample,permutationDims);
                    miniBatch((outSequenceLength+1):end,sampleIdx,:)=sequencePaddingValue;
                else
                    miniBatch((1-outSequenceLength:0)+end,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample,permutationDims);
                    miniBatch(1:(end-outSequenceLength),sampleIdx,:)=sequencePaddingValue;
                end
            end
        else
            for sampleIdx=1:validSamples
                sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};



                sampleSequenceLengths(sampleIdx)=miniBatchSequenceLengthValue;


                if strcmp(coder.const(sequencePaddingDirection),'right')
                    miniBatch(:,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample(:,1:miniBatchSequenceLengthValue),permutationDims);
                else
                    miniBatch(:,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample(:,(1-miniBatchSequenceLengthValue:0)+end),permutationDims);
                end
            end
        end
    else


        miniBatch=coder.internal.DeepLearningNetworkUtils.permuteData(indata,permutationDims);

        miniBatchSequenceLengthValue=size(indata,sequenceDimensionIndex);


        sampleSequenceLengths=miniBatchSequenceLengthValue;
    end
end
