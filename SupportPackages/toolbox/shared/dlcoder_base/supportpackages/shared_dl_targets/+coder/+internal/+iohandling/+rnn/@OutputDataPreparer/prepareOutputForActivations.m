%#codegen

function out=prepareOutputForActivations(...
    indata,outputFeatureSize,...
    inBatchSize,miniBatchSize,numMiniBatches,remainder,...
    sequenceLengthMode,isCellInput,isImageInput,isSequenceOutput,isSequenceFolded)



    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;

    outBatchSize=iGetOutBatchSize(indata,inBatchSize,miniBatchSize,numMiniBatches,remainder,sequenceLengthMode,isCellInput,isImageInput,isSequenceFolded);


    out=iGetOutVariable(isSequenceOutput,outputFeatureSize,outBatchSize,isSequenceFolded);
end

function outBatchSize=iGetOutBatchSize(indata,inBatchSize,miniBatchSize,numMiniBatches,remainder,sequenceLengthMode,isCellInput,isImageInput,isSequenceFolded)
    coder.inline('always');
    if coder.const(isSequenceFolded)








        outBatchSize=iGetFoldedBatchSize(indata,miniBatchSize,numMiniBatches,remainder,sequenceLengthMode,isCellInput,isImageInput);
    else
        outBatchSize=inBatchSize;
    end
end

function foldedBatchSize=iGetFoldedBatchSize(indata,miniBatchSize,numMiniBatches,remainder,sequenceLengthMode,isCellInput,isImageInput)
    coder.inline('always');
    if coder.const(~isCellInput)

        foldedBatchSize=iGetSequenceLengthFromSample(indata,isImageInput);
    else
        miniBatchSequenceLengths=coder.nullcopy(ones(numMiniBatches,1));

        if coder.const(strcmp(sequenceLengthMode,'longest'))



            coder.unroll();
            for miniBatchIdx=1:numMiniBatches
                maxMBSL=0;







                if coder.const((remainder>0)&&(miniBatchIdx==numMiniBatches))
                    validSamples=remainder;
                else
                    validSamples=miniBatchSize;
                end

                for sampleIdx=(1:validSamples)+(miniBatchSize*(miniBatchIdx-1))
                    sampleSL=iGetSequenceLengthFromSample(indata{sampleIdx},isImageInput);
                    if sampleSL>maxMBSL
                        miniBatchSequenceLengths(miniBatchIdx)=sampleSL;
                        maxMBSL=sampleSL;
                    end
                end
            end
        else





            coder.unroll();
            for miniBatchIdx=1:numMiniBatches
                minMBSL=realmax;







                if coder.const((remainder>0)&&(miniBatchIdx==numMiniBatches))
                    validSamples=remainder;
                else
                    validSamples=miniBatchSize;
                end

                for sampleIdx=(1:validSamples)+(miniBatchSize*(miniBatchIdx-1))
                    sampleSL=iGetSequenceLengthFromSample(indata{sampleIdx},isImageInput);
                    if sampleSL<minMBSL
                        miniBatchSequenceLengths(miniBatchIdx)=sampleSL;
                        minMBSL=sampleSL;
                    end
                end
            end
        end

        foldedBatchSize=0;
        for miniBatchIdx=1:numMiniBatches
            foldedBatchSize=foldedBatchSize+(miniBatchSequenceLengths(miniBatchIdx)*miniBatchSize);
        end


        if remainder>0
            foldedBatchSize=foldedBatchSize-(miniBatchSequenceLengths(numMiniBatches)*(miniBatchSize-remainder));
        end
    end
end


function sequenceLength=iGetSequenceLengthFromSample(sample,isImageInput)
    coder.inline('always');
    if iscell(sample)
        sample=sample{1};
    end

    if coder.const(isImageInput)
        sequenceLength=size(sample,4);
    else
        sequenceLength=size(sample,2);
    end
end


function out=iGetOutVariable(isSequenceOutput,outputFeatureSize,outBatchSize,isSequenceFolded)
    coder.inline('always');






    if coder.const(isSequenceOutput)




        assert(coder.const(~isSequenceFolded));
        out=coder.nullcopy(cell(outBatchSize,1));
    else




        out=coder.nullcopy(zeros([outputFeatureSize,outBatchSize],'single'));
    end
end
