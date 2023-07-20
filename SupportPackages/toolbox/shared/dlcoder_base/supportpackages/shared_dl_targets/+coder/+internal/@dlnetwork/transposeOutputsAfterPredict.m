function outputDataT=transposeOutputsAfterPredict(obj,outputData,numOutputsRequested,outputFormats)















%#codegen



    coder.internal.prefer_const(numOutputsRequested,outputFormats);
    coder.allowpcode('plain');
    coder.inline('always');

    outputDataT=cell(1,numOutputsRequested);
    coder.unroll();
    for opIdx=1:numOutputsRequested

        [isImageOutput,outputHasTimeDim]=coder.const(@coder.internal.dlnetwork.processOutputFormat,outputFormats{opIdx});

        if coder.const(outputHasTimeDim)

            if isImageOutput
                isDataOutput=true;
                outputDataT{opIdx}=obj.permuteImageSequenceData(outputData{opIdx},isDataOutput,...
                coder.const(outputFormats{opIdx}));
            else
                outputDataT{opIdx}=obj.permuteVectorSequenceData(outputData{opIdx},coder.const(outputFormats{opIdx}));
            end

        else
            if coder.const(numel(outputFormats{opIdx})>2)
                outputDataT{opIdx}=permuteImageOutput(outputData{opIdx},coder.const(outputFormats{opIdx}));
            else
                outputDataT{opIdx}=obj.permuteFeatureData(outputData{opIdx});
            end
        end
    end
end
