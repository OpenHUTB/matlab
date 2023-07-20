%#codegen



function reshapedSample=prepareRNNCellOutput(obj,outMiniBatch,outputFeatureSize,sampleSequenceLengths,...
    sequenceLengthMode,sequencePaddingDirection,sampleIdx,isImageOutput)




    coder.allowpcode('plain');


    if isImageOutput

        if strcmp(sequenceLengthMode,'longest')
            if strcmp(sequencePaddingDirection,'right')
                unpaddedSample=outMiniBatch(:,:,:,sampleIdx,1:sampleSequenceLengths(sampleIdx));
            else
                unpaddedSample=outMiniBatch(:,:,:,sampleIdx,end-sampleSequenceLengths(sampleIdx)+1:end);
            end
        else


            unpaddedSample=outMiniBatch(:,:,:,sampleIdx,:);
        end

        reshapedSample=reshape(unpaddedSample,...
        [outputFeatureSize,sampleSequenceLengths(sampleIdx)]);
    else

        if strcmp(sequenceLengthMode,'longest')
            if strcmp(sequencePaddingDirection,'right')
                unpaddedSample=outMiniBatch(:,sampleIdx,1:sampleSequenceLengths(sampleIdx));
            else
                unpaddedSample=outMiniBatch(:,sampleIdx,end-sampleSequenceLengths(sampleIdx)+1:end);
            end
        else


            unpaddedSample=outMiniBatch(:,sampleIdx,:);
        end
        reshapedSample=reshape(unpaddedSample,...
        [outputFeatureSize,sampleSequenceLengths(sampleIdx)]);
    end
end
