function inputSize=getInputSizeBasedOnFormat(codegenInputSize,inputLayerFormat,exampleSequenceLength)























    inputHasSpatial=contains(inputLayerFormat,'S');
    inputHasBatch=contains(inputLayerFormat,'B');
    inputHasTime=contains(inputLayerFormat,'T');

    inputSize=codegenInputSize;
    if inputHasSpatial
        if~inputHasTime



            if~inputHasBatch

                inputSize=codegenInputSize(1:end-1);
            end
        else
            if~inputHasBatch

                inputSize=[codegenInputSize(1:end-1),exampleSequenceLength];
            else

                inputSize=[codegenInputSize,exampleSequenceLength];
            end
        end

    else

        if~inputHasTime
            if~inputHasBatch

                inputSize=[codegenInputSize(3),1];
            else

                inputSize=codegenInputSize(3:4);
            end
        else
            if~inputHasBatch

                inputSize=[codegenInputSize(3),exampleSequenceLength];
            else

                inputSize=[codegenInputSize(3:4),exampleSequenceLength];
            end
        end

    end

end
