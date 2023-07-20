%#codegen












function out=prepareOutputForPredict(in,outputFeatureSize,batchSize,isCellInput,isImageInput,isImageOutput,isSequenceOutput)



    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;


    if~isSequenceOutput
        if isImageOutput

            out=coder.nullcopy(zeros([outputFeatureSize,batchSize],'single'));
        else

            out=coder.nullcopy(zeros(batchSize,outputFeatureSize,'single'));
        end
    elseif isCellInput

        out=coder.nullcopy(cell(batchSize,1));
    else

        if isImageInput
            sequenceLengthDimension=size(in,4);
        else
            sequenceLengthDimension=size(in,2);
        end





        out=coder.nullcopy(zeros([outputFeatureSize,sequenceLengthDimension],'single'));
    end
end
