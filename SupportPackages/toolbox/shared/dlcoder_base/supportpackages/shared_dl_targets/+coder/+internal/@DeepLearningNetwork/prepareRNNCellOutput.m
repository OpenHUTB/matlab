%#codegen


function reshapedSample=prepareRNNCellOutput(obj,outMiniBatch,outputFeatureSize,sampleSequenceLengths,...
    sequenceLengthMode,sequencePaddingDirection,sampleIdx,isImageOutput)




    coder.allowpcode('plain');






    coder.extrinsic('coder.internal.iohandling.rnn.OutputDataPreparer.getOutputFeatureSizeC');
    outputFeatureSizeC=coder.const(...
    @coder.internal.iohandling.rnn.OutputDataPreparer.getOutputFeatureSizeC,...
    outputFeatureSize,...
    isImageOutput,...
    coder.isRowMajor);


    if isImageOutput
        if coder.isRowMajor
            if strcmp(sequenceLengthMode,'longest')
                if strcmp(sequencePaddingDirection,'right')
                    unpaddedSample=outMiniBatch(1:sampleSequenceLengths(sampleIdx),sampleIdx,:,:,:);
                else
                    unpaddedSample=outMiniBatch(end-sampleSequenceLengths(sampleIdx)+1:end,sampleIdx,:,:,:);
                end
            else


                unpaddedSample=outMiniBatch(:,sampleIdx,:,:,:);
            end

            reshapedSample=(reshape(unpaddedSample,...
            [sampleSequenceLengths(sampleIdx),outputFeatureSizeC]));


            reshapedSample=permute(reshapedSample,[3,4,2,1]);
        else
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
            [outputFeatureSizeC,sampleSequenceLengths(sampleIdx)]);


            reshapedSample=permute(reshapedSample,[2,1,3,4]);
        end
    else
        if coder.isRowMajor
            if strcmp(sequenceLengthMode,'longest')
                if strcmp(sequencePaddingDirection,'right')
                    unpaddedSample=outMiniBatch(1:sampleSequenceLengths(sampleIdx),sampleIdx,:);
                else
                    unpaddedSample=outMiniBatch(end-sampleSequenceLengths(sampleIdx)+1:end,sampleIdx,:);
                end
            else


                unpaddedSample=outMiniBatch(:,sampleIdx,:);
            end

            reshapedSample=(reshape(unpaddedSample,...
            [sampleSequenceLengths(sampleIdx),outputFeatureSizeC]))';
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
            [outputFeatureSizeC,sampleSequenceLengths(sampleIdx)]);
        end
    end
end
