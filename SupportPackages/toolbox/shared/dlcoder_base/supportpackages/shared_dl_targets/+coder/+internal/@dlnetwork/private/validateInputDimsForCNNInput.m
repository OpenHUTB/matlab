%#codegen







function validateInputDimsForCNNInput(indata,isInputImageType)




    coder.allowpcode('plain');
    coder.internal.prefer_const(isInputImageType);

    if isInputImageType


        coder.internal.assert(numel(size(indata))<=4,'dlcoder_spkg:cnncodegen:InvalidInputImageData');



        actualInputSize=[size(indata,1),size(indata,2),size(indata,3)];
        coder.internal.assert(coder.internal.isConst(actualInputSize),...
        'dlcoder_spkg:cnncodegen:VariableSizeInput');
        batchSize=size(indata,4);


        coder.internal.assert(coder.internal.isConst(batchSize),...
        'dlcoder_spkg:cnncodegen:VariableBatchSize',...
        'predict');


    else


        coder.internal.assert(numel(size(indata))<=2,'dlcoder_spkg:cnncodegen:InvalidInputVectorData');



        actualInputSize=size(indata,1);
        coder.internal.assert(coder.internal.isConst(actualInputSize),...
        'dlcoder_spkg:cnncodegen:VariableSizeInput');
        batchSize=size(indata,2);


        coder.internal.assert(coder.internal.isConst(batchSize),...
        'dlcoder_spkg:cnncodegen:VariableBatchSize',...
        'predict');

    end

end
