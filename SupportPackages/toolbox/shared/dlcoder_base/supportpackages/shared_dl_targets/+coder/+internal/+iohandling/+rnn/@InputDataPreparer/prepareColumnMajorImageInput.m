%#codegen











function[miniBatch,sampleSequenceLengths,miniBatchSequenceLengthValue]=...
    prepareColumnMajorImageInput(indata,inputSize,miniBatchSize,...
    sequenceLengthMode,sequencePaddingValue,sequencePaddingDirection,...
    isCellInput,...
    miniBatchIdx,numMiniBatches,remainder,permutationDims)




    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    height=inputSize(1);
    width=inputSize(2);
    channels=inputSize(3);
    sequenceDimensionIndex=4;


    if isCellInput
        sampleSequenceLengths=coder.nullcopy(zeros(miniBatchSize,1));

        miniBatchSequenceLengthValue=...
        coder.internal.DeepLearningNetworkUtils.getSequenceLengthRNNCellInput(...
        indata,miniBatchSize,miniBatchIdx,sequenceLengthMode,numMiniBatches,remainder,true);

        if coder.const(any(strcmp(coder.internal.coderNetworkUtils.getTargetLib(),{'none','cmsis-nn'})))

            miniBatchDimensions=[height,width,channels,miniBatchSize,miniBatchSequenceLengthValue];
        else



            miniBatchDimensions=[width,height,channels,miniBatchSize,miniBatchSequenceLengthValue];
        end

        miniBatch=coder.nullcopy(zeros(miniBatchDimensions,'like',indata{1}));







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

                    miniBatch(:,:,:,sampleIdx,1:outSequenceLength)=coder.internal.DeepLearningNetworkUtils.permuteData(sample,permutationDims);
                    miniBatch(:,:,:,sampleIdx,(outSequenceLength+1):end)=sequencePaddingValue;
                else

                    miniBatch(:,:,:,sampleIdx,(1-outSequenceLength:0)+end)=coder.internal.DeepLearningNetworkUtils.permuteData(sample,permutationDims);
                    miniBatch(:,:,:,sampleIdx,1:(end-outSequenceLength))=sequencePaddingValue;
                end
            end
        else
            for sampleIdx=1:validSamples
                sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};




                sampleSequenceLengths(sampleIdx)=miniBatchSequenceLengthValue;


                if strcmp(coder.const(sequencePaddingDirection),'right')
                    miniBatch(:,:,:,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample(:,:,:,1:miniBatchSequenceLengthValue),permutationDims);
                else
                    miniBatch(:,:,:,sampleIdx,:)=coder.internal.DeepLearningNetworkUtils.permuteData(sample(:,:,:,(1-miniBatchSequenceLengthValue:0)+end),permutationDims);
                end
            end
        end
    else




        miniBatch=coder.internal.DeepLearningNetworkUtils.permuteData(indata,permutationDims);

        miniBatchSequenceLengthValue=size(indata,sequenceDimensionIndex);


        sampleSequenceLengths=miniBatchSequenceLengthValue;
    end
end
