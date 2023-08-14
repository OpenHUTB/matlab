function[isImageOutput,outputHasTimeDim]=processOutputFormat(outputFormat)








%#codegen



    coder.inline('always');
    coder.allowpcode('plain');
    coder.internal.prefer_const(outputFormat);

    outputTimeDim=coder.const(findDim(outputFormat,'T'));
    spatialDims=coder.const(findDim(outputFormat,'S'));
    isImageOutput=coder.const(numel(spatialDims)==2);

    if coder.const(~isempty(outputTimeDim))
        outputHasTimeDim=true;
    else
        outputHasTimeDim=false;
    end

end