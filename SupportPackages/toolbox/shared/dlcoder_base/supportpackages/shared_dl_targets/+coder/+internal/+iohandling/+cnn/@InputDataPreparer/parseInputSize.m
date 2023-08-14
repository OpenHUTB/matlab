%#codegen














function[height,width,channels,batchSize]=parseInputSize(in,trainingInputSize,callerFunction,targetLib)




    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.allowHalfInputs;

    coder.internal.assert(coder.const(~isa(in,'dlarray')),...
    'dlcoder_spkg:cnncodegen:DlarrayInputNotSupported');

    coder.internal.assert(coder.const(~islogical(in)),...
    'dlcoder_spkg:cnncodegen:invalid_input',...
    callerFunction);

    numInputDims=coder.const(numel(trainingInputSize));









    hasUnsupportedSpatialDimsInInputFormat=coder.const(numInputDims==2)||coder.const(numInputDims==4);

    if coder.const(hasUnsupportedSpatialDimsInInputFormat)
        numSpatialDimensions=numInputDims-1;
        coder.internal.errorIf(hasUnsupportedSpatialDimsInInputFormat,...
        'dlcoder_spkg:cnncodegen:unsupportedSpatialDimensions',numSpatialDimensions)
    end

    isInputImageType=coder.const(numInputDims==3);


    if coder.const(isInputImageType)



        coder.internal.assert(numel(size(in))<=4,'dlcoder_spkg:cnncodegen:InvalidInputImageData');
        coder.internal.assert(coder.internal.isConst([size(in,1),size(in,2),size(in,3)]),...
        'dlcoder_spkg:cnncodegen:VariableSizeInput');


        height=coder.const(size(in,1));
        width=coder.const(size(in,2));
        channels=coder.const(size(in,3));
        batchSize=size(in,4);
    else



        coder.internal.assert(numel(size(in))<=2,'dlcoder_spkg:cnncodegen:InvalidInputVectorData');
        coder.internal.assert(coder.internal.isConst(size(in,3)),...
        'dlcoder_spkg:cnncodegen:VariableSizeInput');


        height=1;
        width=1;
        channels=coder.const(size(in,2));
        batchSize=size(in,1);
    end


    coder.internal.assert(coder.internal.isConst(batchSize),...
    'dlcoder_spkg:cnncodegen:VariableBatchSize',...
    callerFunction);
end
