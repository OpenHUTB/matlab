function inputDataT=transposeInputsBeforePredict(obj,dataInputs,inputHasTimeDim,isImageInput,inputFormats)

















%#codegen



    coder.internal.prefer_const(inputHasTimeDim,isImageInput,inputFormats);
    coder.allowpcode('plain');
    coder.inline('always');

    numInputs=coder.const(numel(inputHasTimeDim));
    inputDataT=cell(numInputs,1);


    coder.unroll();
    for ipIdx=1:numInputs

        if inputHasTimeDim(ipIdx)
            if isImageInput(ipIdx)

                isDataOutput=false;
                inputDataT{ipIdx}=obj.permuteImageSequenceData(dataInputs{ipIdx},isDataOutput,...
                coder.const(inputFormats{ipIdx}));
            else

                inputDataT{ipIdx}=obj.permuteVectorSequenceData(dataInputs{ipIdx},coder.const(inputFormats{ipIdx}));
            end

        else
            if isImageInput(ipIdx)

                inputDataT{ipIdx}=coder.internal.iohandling.cnn.InputDataPreparer.permuteImageInput(dataInputs{ipIdx},obj.DLTargetLib);
            else

                inputDataT{ipIdx}=obj.permuteFeatureData(dataInputs{ipIdx});
            end

        end

    end
end



