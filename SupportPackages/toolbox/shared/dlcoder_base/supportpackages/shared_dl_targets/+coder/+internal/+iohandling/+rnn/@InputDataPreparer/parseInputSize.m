%#codegen




















function[height,width,channels,batchSize]=parseInputSize(indata,trainingInputSize,isCellInput)





    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;








    numInputDims=coder.const(numel(trainingInputSize));
    hasUnsupportedSpatialDimsInInputFormat=coder.const(numInputDims==2)||coder.const(numInputDims==4);

    if coder.const(hasUnsupportedSpatialDimsInInputFormat)
        if coder.const(numInputDims==2)
            numSpatialDimensions=1;
        elseif coder.const(numInputDims==4)
            numSpatialDimensions=3;
        end
        coder.internal.errorIf(hasUnsupportedSpatialDimsInInputFormat,...
        'dlcoder_spkg:cnncodegen:unsupportedSpatialDimensions',numSpatialDimensions)
    end

    coder.internal.assert(numInputDims==1||numInputDims==3,'dlcoder_spkg:cnncodegen:DLCoderInternalError');

    isInputImageType=numInputDims==3;
    if isCellInput




        coder.internal.assert(...
        numel(size(indata))<3&&...
        size(indata,1)>0&&...
        size(indata,2)==1,...
        'dlcoder_spkg:cnncodegen:BadCellArrayFormat');


        batchSize=size(indata,1);
        coder.internal.assert(coder.internal.isConst(batchSize),...
        'dlcoder_spkg:cnncodegen:VariableBatchSize',...
        'predict');

        if coder.const(~isInputImageType)
            height=1;
            width=1;
            channels=size(indata{1},1);
            for i=1:numel(indata)
                validateSingleSequence(indata{i},channels);
            end
        else
            height=size(indata{1},1);
            width=size(indata{1},2);
            channels=size(indata{1},3);

            for i=1:numel(indata)
                validateSingleImageSequence(indata{i},height,width,channels);
            end
        end
    else
        batchSize=1;

        if coder.const(~isInputImageType)
            height=1;
            width=1;
            channels=size(indata,1);

            validateSingleSequence(indata,channels);

        else
            height=size(indata,1);
            width=size(indata,2);
            channels=size(indata,3);

            validateSingleImageSequence(indata,height,width,channels);
        end
    end
end

function validateSingleSequence(sequence,featureDim)
    coder.internal.allowHalfInputs;

    coder.internal.assert(coder.const(~isa(sequence,'dlarray')),...
    'dlcoder_spkg:cnncodegen:DlarrayInputNotSupported');


    coder.internal.assert(coder.internal.isConst(size(sequence,1)),...
    'dlcoder_spkg:cnncodegen:VariableFeatureDimension',...
    'predict');

    coder.internal.assert(size(sequence,1)==featureDim,...
    'dlcoder_spkg:cnncodegen:TimeseriesHaveDifferentFeatureDimensions');





    coder.internal.assert(...
    numel(size(sequence))<3&&...
    isnumeric(sequence)&&...
    size(sequence,1)>0&&...
    size(sequence,2)>0,...
    'dlcoder_spkg:cnncodegen:BadTimeseriesFormat');
end

function validateSingleImageSequence(sequence,height,width,channels)

    coder.internal.assert(coder.const(~isa(sequence,'dlarray')),...
    'dlcoder_spkg:cnncodegen:DlarrayInputNotSupported');


    coder.internal.assert(coder.internal.isConst(size(sequence,1)),...
    'dlcoder_spkg:cnncodegen:VariableHeight',...
    'predict');


    coder.internal.assert(coder.internal.isConst(size(sequence,2)),...
    'dlcoder_spkg:cnncodegen:VariableWidth',...
    'predict');


    coder.internal.assert(coder.internal.isConst(size(sequence,3)),...
    'dlcoder_spkg:cnncodegen:VariableChannels',...
    'predict');

    coder.internal.assert(size(sequence,1)==height,...
    'dlcoder_spkg:cnncodegen:TimeseriesHaveDifferentHeights');

    coder.internal.assert(size(sequence,2)==width,...
    'dlcoder_spkg:cnncodegen:TimeseriesHaveDifferentWidths');

    coder.internal.assert(size(sequence,3)==channels,...
    'dlcoder_spkg:cnncodegen:TimeseriesHaveDifferentChannels');





    coder.internal.assert(...
    numel(size(sequence))<5&&...
    isnumeric(sequence)&&...
    size(sequence,1)>0&&...
    size(sequence,2)>0&&...
    size(sequence,3)>0&&...
    size(sequence,4)>0,...
    'dlcoder_spkg:cnncodegen:BadTimeseriesFormat');
end
