%#codegen





function varargout=predict(obj,varargin)





    coder.allowpcode('plain');
    coder.inline('never');

    coder.gpu.internal.kernelfunImpl(false);


    minArgsIn=coder.const(obj.NumInputLayers);
    iValidateNumInputs(minArgsIn,(nargin-1));


    numOutputsRequested=coder.const(nargout);
    numInputs=coder.const(obj.NumInputLayers);


    outputNames=coder.const(coder.internal.dlnetwork.parseInputsCodegenPredict(varargin{numInputs+1:end}));


    numNetworkOutPorts=coder.const(numel(obj.OutputNames));
    numOutputsExpected=iValidateStateOutput(numOutputsRequested,numNetworkOutPorts,outputNames);
    nargoutchk(0,numOutputsExpected);

    dataInputs={varargin{1:numInputs}};
    dataInputsSingle=cell(numInputs,1);
    inputFormats=cell(numInputs,1);

    isImageInput=coder.nullcopy(zeros(numInputs,1));

    inputSizesForPropagation=cell(numInputs,1);


    inputSizesForCodegen=cell(numInputs,1);


    inputHasTimeDim=coder.nullcopy(false(numInputs,1));


    inputSequenceLengths=coder.nullcopy(zeros(numInputs,1));


    oldInputSizes=coder.internal.getprop_if_defined(obj.CodegenInputSizes);


    oldInputFormats=coder.internal.getprop_if_defined(obj.CodegenInputFormats);


    isInputSequenceVarsized=false;

    exampleSequenceLengths=coder.const(@feval,'coder.internal.coderNetworkUtils.getExampleSequenceLengths',obj.DLTNetwork);

    coder.unroll();

    for inputIdx=1:numInputs


        [dataInputsSingle{inputIdx},inputFormats{inputIdx}]=iExtractInputDataAndFormat(dataInputs{inputIdx});


        [isImageInput(inputIdx),inputHasTimeDim(inputIdx),isInputSequenceVarsized,...
        inputSequenceLengths(inputIdx),inputSizesForCodegen{inputIdx},...
        inputSizesForPropagation{inputIdx}]=...
        iProcessInputDataAndFormat(obj,inputIdx,dataInputsSingle{inputIdx},...
        inputFormats{inputIdx},isInputSequenceVarsized,exampleSequenceLengths(inputIdx));



        if~isempty(oldInputSizes)
            coder.internal.iohandling.cnn.InputDataPreparer.checkInputsForVaryingSize(oldInputSizes{inputIdx},inputSizesForCodegen{inputIdx},'predict');
        end


        if~isempty(oldInputFormats)
            coder.internal.iohandling.cnn.InputDataPreparer.checkInputsForVaryingFormats(oldInputFormats{inputIdx},inputFormats{inputIdx},'predict');
        end

    end


    obj.CodegenInputSizes=inputSizesForCodegen;


    obj.CodegenInputFormats=inputFormats;


    obj.setSizeDependentProperties(inputFormats);





    if~isequal(inputSizesForCodegen,oldInputSizes)
        obj.validate();
    end




    obj.setNetworkInfoDependentProperties();


    [outsizes,outputFormats]=coder.const(@iGetOutputSizesForInput,obj,inputSizesForPropagation,inputFormats,outputNames);


    [sortedOutputLayerIndices,sortedOutputPortIndices]=coder.const(@feval,'coder.internal.dlnetwork.getOutputIndices',obj.DLTNetwork,numOutputsRequested,outputNames,obj.DLTargetLib);




    inputDataT=transposeInputsBeforePredict(obj,dataInputsSingle,inputHasTimeDim,isImageInput,inputFormats);



    if coder.const(any(inputHasTimeDim))
        obj.callSetSize(inputSequenceLengths,inputHasTimeDim);
    end



    outputData=obj.callPredict(inputDataT,coder.const(outsizes),isInputSequenceVarsized,outputFormats,...
    numOutputsRequested,sortedOutputLayerIndices,sortedOutputPortIndices);


    outputDataAfterTranspose=transposeOutputsAfterPredict(obj,outputData,numOutputsRequested,outputFormats);

    varargout=coder.internal.coderNetworkUtils.getDlarrayDataFromNumericData(outputDataAfterTranspose,outputFormats);

end





function[outsizes,outFormats]=iGetOutputSizesForInput(obj,inputSizes,inputFormats,outputNames)
    coder.inline('always');
    coder.extrinsic('coder.internal.dlnetwork.getOutputSizes');

    [outsizes,outFormats]=coder.const(...
    @coder.internal.dlnetwork.getOutputSizes,...
    obj.DLTNetwork,...
    inputSizes,...
    inputFormats,...
    outputNames);

end



function iCheckforVaryingBatchSize(oldNumObservations,newNumObservations)
    if~isempty(oldNumObservations)

        coder.internal.assert(coder.const(@isequal,oldNumObservations,newNumObservations),...
        'dlcoder_spkg:cnncodegen:VaryingBatchSize',...
        oldNumObservations,...
        newNumObservations,...
'predict'...
        );
    end
end





function iValidateInputData(indata,inputFormat,isInputImageType,hasSequenceDim)
    coder.inline('always');

    coder.internal.prefer_const(isInputImageType,inputFormat,hasSequenceDim);

    coder.extrinsic('coder.internal.iohandling.rnn.InputDataPreparer.checkInputSize');

    coder.internal.errorIf(coder.const(islogical(indata)),...
    'dlcoder_spkg:cnncodegen:invalid_input',...
    'predict');

    if hasSequenceDim

        validateInputDimsForSequenceInput(indata,isInputImageType,inputFormat);

    else
        validateInputDimsForCNNInput(indata,isInputImageType);
    end

end

function iValidateInputSize(codegenInputSize,trainingInputSize,isInputImageType,hasSequenceDim)
    coder.internal.prefer_const(codegenInputSize,trainingInputSize,isInputImageType,hasSequenceDim)

    callerFunction='predict';

    if coder.const(hasSequenceDim)


        coder.const(...
        @coder.internal.iohandling.rnn.InputDataPreparer.checkInputSize,...
        codegenInputSize(1:3),...
        trainingInputSize,...
        callerFunction,...
        isInputImageType);

    end

end

function inputSizeForPropagation=iGetInputSizeForPropagation(data,timeDim,exampleSequenceLength)
    coder.internal.prefer_const(timeDim);

    if coder.const(isempty(timeDim))
        inputSizeForPropagation=coder.const(size(data));
        return;
    end

    if coder.internal.isConst(size(data,timeDim))

        inputSizeForPropagation=coder.const(size(data));
    else
        extractedInputSize=size(data);
        extractedInputSize(timeDim)=exampleSequenceLength;
        inputSizeForPropagation=coder.const(extractedInputSize);
    end

end


function iValidateNumInputs(expectedNumInputs,actualNumberOfInputs)
    coder.inline('always');

    coder.internal.assert(actualNumberOfInputs>=expectedNumInputs,'dlcoder_spkg:cnncodegen:InsufficientInputs',expectedNumInputs);
end

function numOutputsExpected=iValidateStateOutput(numOutputsRequested,numNetworkOutPorts,activationNames)
    coder.inline('always');

    numOutputsExpected=numNetworkOutPorts;
    if~isempty(activationNames)
        numOutputsExpected=numel(activationNames);
    end

    coder.internal.errorIf(numOutputsRequested==numOutputsExpected+1,'dlcoder_spkg:dlnetwork:ReturningStateNotSupported');

end


function iValidateFormattedDlarray(dlIn)

    coder.internal.errorIf(~isa(dlIn,'dlarray'),'dlcoder_spkg:dlnetwork:UnsupportedInputFormat');

    fmt=dims(dlIn);
    coder.internal.errorIf(isempty(fmt),'dlcoder_spkg:dlnetwork:UnformattedDLArrayNotSupported','predict');

end

function iValidateInputDataType(input)

    coder.internal.errorIf(~isa(input,'single'),'dlcoder_spkg:dlnetwork:UnsupportedInputDataType',class(input));

end





function inputsize=getCodegenInputSize(extractedInput,isImageInput,inputFormat,hasSequenceDim)
    coder.internal.prefer_const(isImageInput,inputFormat,hasSequenceDim);
    hasBatchDim=hasDimension(coder.const(inputFormat),'B');

    if coder.const(hasSequenceDim)
        if isImageInput

            if~hasBatchDim

                inputsize=[size(extractedInput,1:3),1];
            else

                inputsize=size(extractedInput,1:4);
            end
        else

            if~hasBatchDim

                inputsize=[1,1,size(extractedInput,1),1];
            else

                inputsize=[1,1,size(extractedInput,1:2)];
            end
        end
    else
        if isImageInput

            inputsize=size(extractedInput,1:4);
        else

            inputsize=[1,1,size(extractedInput,1:2)];
        end
    end

end

function[dataInputSingle,inputFormat]=iExtractInputDataAndFormat(dlIn)
    coder.inline('always');

    iValidateFormattedDlarray(dlIn);


    extractedInput=extractdata(dlIn);





    if~(coder.internal.isAmbiguousTypes()||coder.internal.isAmbiguousComplexity())

        iValidateInputDataType(extractedInput);

    end


    dataInputSingle=single(extractedInput);


    inputFormat=coder.const(dims(dlIn));



    iValidateNetworkInput(inputFormat);

end

function iValidateNetworkInput(inputFormat)
    numSpatialDimensions=count(inputFormat,'S');
    hasUnsupportedSpatialDimsInInputFormat=numSpatialDimensions==1||numSpatialDimensions>=3;

    coder.internal.errorIf(hasUnsupportedSpatialDimsInInputFormat,...
    'dlcoder_spkg:cnncodegen:unsupportedSpatialDimensions',numSpatialDimensions);

    isCUFormat=strcmp(inputFormat,'CU');




    hasUnsupportedUnspecifiedDimsInInputFormat=~isCUFormat&&...
    count(inputFormat,'U')>=1;

    coder.internal.errorIf(hasUnsupportedUnspecifiedDimsInInputFormat,...
    'dlcoder_spkg:cnncodegen:unsupportedUnspecifiedDimensions');

end


function[isImageInput,inputHasTimeDim,isInputSequenceVarsized,...
    inputSequenceLength,inputSizeForCodegen,inputSizeForPropagation]=...
    iProcessInputDataAndFormat(obj,inputIdx,dataInput,inputFormat,isInputSequenceVarsized,exampleSequenceLength)

    coder.inline('always');
    coder.internal.prefer_const(inputIdx,inputFormat,isInputSequenceVarsized);



    spatialDims=findDim(inputFormat,'S');
    isImageInput=numel(spatialDims)==2;

    timeDim=coder.const(findDim(coder.const(inputFormat),'T'));

    inputHasTimeDim=~isempty(timeDim);

    if inputHasTimeDim
        inputSequenceLength=size(dataInput,timeDim);

        if~isInputSequenceVarsized




            isInputSequenceVarsized=~coder.internal.isConst(inputSequenceLength);

        end

    else
        inputSequenceLength=-1;
    end


    iValidateInputData(dataInput,inputFormat,isImageInput,inputHasTimeDim);


    inputSizeForCodegen=getCodegenInputSize(dataInput,isImageInput,inputFormat,inputHasTimeDim);


    iValidateInputSize(inputSizeForCodegen,obj.NetworkInputSizes{inputIdx},isImageInput,inputHasTimeDim);


    inputSizeForPropagation=coder.const(iGetInputSizeForPropagation(dataInput,timeDim,exampleSequenceLength));

end


