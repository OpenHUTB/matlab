%#codegen










function validateInputDimsForSequenceInput(indata,isInputImageType,inputFormat)




    coder.allowpcode('plain');
    coder.internal.prefer_const(isInputImageType,inputFormat);

    if coder.const(~isInputImageType)

        validateSingleSequence(indata);

    else

        validateSingleImageSequence(indata);
    end

    batchDim=findDim(coder.const(inputFormat),'B');

    if~isempty(batchDim)
        batchSize=size(indata,batchDim);
    else
        batchSize=1;
    end


    coder.internal.assert(coder.internal.isConst(batchSize),...
    'dlcoder_spkg:cnncodegen:VariableBatchSize',...
    'predict');

end

function validateSingleSequence(sequence)


    coder.internal.assert(coder.internal.isConst(size(sequence,1)),...
    'dlcoder_spkg:cnncodegen:VariableFeatureDimension',...
    'predict');




    coder.internal.assert(...
    numel(size(sequence))<4&&...
    isnumeric(sequence)&&...
    size(sequence,1)>0,...
    'dlcoder_spkg:cnncodegen:BadTimeseriesFormat');
end

function validateSingleImageSequence(sequence)



    coder.internal.assert(coder.internal.isConst(size(sequence,1)),...
    'dlcoder_spkg:cnncodegen:VariableHeight',...
    'predict');


    coder.internal.assert(coder.internal.isConst(size(sequence,2)),...
    'dlcoder_spkg:cnncodegen:VariableWidth',...
    'predict');


    coder.internal.assert(coder.internal.isConst(size(sequence,3)),...
    'dlcoder_spkg:cnncodegen:VariableChannels',...
    'predict');





    coder.internal.assert(...
    numel(size(sequence))<6&&...
    isnumeric(sequence)&&...
    size(sequence,1)>0&&...
    size(sequence,2)>0&&...
    size(sequence,3)>0,...
    'dlcoder_spkg:cnncodegen:BadTimeseriesFormat');
end
