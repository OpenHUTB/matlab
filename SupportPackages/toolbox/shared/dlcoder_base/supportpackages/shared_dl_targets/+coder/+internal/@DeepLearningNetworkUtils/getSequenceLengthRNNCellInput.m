%#codegen




function sequenceLength=getSequenceLengthRNNCellInput(indata,miniBatchSize,miniBatchIdx,sequenceLengthMode,numMiniBatches,remainder,isImageInput)

    coder.allowpcode('plain');






    coder.const(sequenceLengthMode);







    if(remainder>0)&&(miniBatchIdx==numMiniBatches)
        validSamples=remainder;
    else
        validSamples=miniBatchSize;
    end


    if coder.const(isImageInput)
        sequenceDimensionIndex=4;
    else
        sequenceDimensionIndex=2;
    end



    if coder.const(strcmp(sequenceLengthMode,'longest'))
        sequenceLength=0;

        for sampleIdx=1:validSamples
            sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};


            if size(sample,sequenceDimensionIndex)>sequenceLength
                sequenceLength=size(sample,sequenceDimensionIndex);
            end

        end
    else
        sequenceLength=realmax;

        for sampleIdx=1:validSamples
            sample=indata{miniBatchSize*(miniBatchIdx-1)+sampleIdx};


            if size(sample,sequenceDimensionIndex)<sequenceLength
                sequenceLength=size(sample,sequenceDimensionIndex);
            end
        end
    end
end
