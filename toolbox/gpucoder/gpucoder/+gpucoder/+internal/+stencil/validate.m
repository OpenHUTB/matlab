function[preprocessFcn,strides,tileSize,useSharedInputBuffer,windowEg,paddingValue,...
    negativePaddingAmounts,positivePaddingAmounts,preprocessOutputEg,stencilFcnOutputsEg,...
    outputEg,skipCallbackChecks]...
    =validate(stencilFcn,input,windowSize,numArgsOut,varargin)
%#codegen



    coder.allowpcode('plain');
    coder.inline('always');

    paramNames={
'Shape'
'Preprocess'
'Stride'
'PaddingValue'

'TileSize'
'UseSharedInputBuffer'
'SkipCallbackChecks'
    };
    pstruct=coder.internal.parseParameterInputs(paramNames,[],varargin{:});
    shape=coder.internal.getParameterValue(pstruct.Shape,'full',varargin{:});
    preprocessFcn=coder.internal.getParameterValue(pstruct.Preprocess,getIdentityFcn(),varargin{:});
    strides0=coder.internal.getParameterValue(pstruct.Stride,1,varargin{:});
    paddingValue0=coder.internal.getParameterValue(pstruct.PaddingValue,[],varargin{:});



    tileSize=coder.internal.getParameterValue(pstruct.TileSize,[16,16],varargin{:});
    useSharedInputBuffer=coder.internal.getParameterValue(pstruct.UseSharedInputBuffer,false,varargin{:});

    skipCallbackChecks=coder.internal.getParameterValue(pstruct.SkipCallbackChecks,false,varargin{:});

    if~coder.target('MATLAB')
        if coder.const(coder.internal.targetLang('gpu'))
            coder.internal.assert(coder.const(coder.internal.targetLang('cuda')),...
            'Coder:builtins:Explicit',...
            'internal: stencilfun is not supported for OpenCL');
        end
    end

    validateSkipCallbackChecks(skipCallbackChecks);
    validateTuningParams(tileSize,useSharedInputBuffer);
    windowEg=validateWindowSize(windowSize);
    validateStrides(strides0);
    validateInput(input);
    paddingValue=validatePaddingValue(paddingValue0,input);
    [negativePaddingAmounts0,positivePaddingAmounts0]=validateShape(shape,windowEg);
    numDims=coder.const(max(coder.internal.ndims(windowEg),coder.internal.ndims(input)));
    if coder.const(isscalar(strides0))
        strides=coder.const(repmat(strides0,[1,numDims]));
    else
        strides=resize(strides0,numDims,1);
    end
    negativePaddingAmounts=resize(negativePaddingAmounts0,numDims,0);
    positivePaddingAmounts=resize(positivePaddingAmounts0,numDims,0);
    preprocessOutputEg=validatePreprocessFcn(preprocessFcn,input);
    stencilFcnOutputsEg=validateStencilFcn(stencilFcn,numArgsOut,windowEg,preprocessOutputEg);
    outputEg=getOutputEg(input,windowEg,negativePaddingAmounts,positivePaddingAmounts,strides);
end


function fcn=getIdentityFcn
    coder.inline('always');
    if coder.const(coder.target('MATLAB'))


        fcn=@(x)x;
    else
        fcn=@identityFcnCodegen;
    end
end

function out=identityFcnCodegen(in)
    coder.inline('always');
    out=in;
end


function validateTuningParams(tileSize,useSharedInputBuffer)
    coder.inline('always');
    coder.internal.assert(coder.const(isscalar(useSharedInputBuffer)&&islogical(useSharedInputBuffer)...
    &&coder.internal.isConst(useSharedInputBuffer)),'Coder:builtins:Explicit',...
    'internal: UseSharedInputBuffer must be a constant logical scalar');
    coder.internal.assert(coder.const(isrow(tileSize)&&isnumeric(tileSize)...
    &&coder.internal.isConst(tileSize)),'Coder:builtins:Explicit',...
    'internal: TileSize must be a constant numeric row vector');
    coder.unroll;
    for i=1:numel(tileSize)
        tileDimSize=tileSize(i);
        coder.internal.assert(coder.const(tileDimSize>0&&floor(tileDimSize)==tileDimSize),...
        'Coder:builtins:Explicit',...
        'internal: TileSize values must be positive integers');
    end
end


function validateSkipCallbackChecks(skipCallbackChecks)
    coder.inline('always');
    coder.internal.assert(coder.const(isscalar(skipCallbackChecks)&&islogical(skipCallbackChecks)...
    &&coder.internal.isConst(skipCallbackChecks)),'Coder:builtins:Explicit',...
    'internal: SkipCallbackChecks must be a constant logical scalar');
end


function windowEg=validateWindowSize(windowSize)
    coder.inline('always');
    coder.internal.assert(coder.const(isrow(windowSize)&&isnumeric(windowSize)...
    &&coder.internal.isConst(windowSize)&&~isempty(windowSize)&&~isscalar(windowSize)),...
    'gpucoder:common:StencilfunInvalidWindowSize');
    coder.unroll;
    for i=1:numel(windowSize)
        dimSize=windowSize(i);
        coder.internal.assert(coder.const(dimSize>0&&dimSize==floor(dimSize)),...
        'gpucoder:common:StencilfunInvalidWindowSize');
    end

    windowEg=coder.nullcopy(false(windowSize));
end


function validateStrides(strides)
    coder.inline('always');
    coder.internal.assert(coder.const(isrow(strides)&&coder.internal.isConst(strides)&&...
    isnumeric(strides)),'gpucoder:common:StencilfunInvalidStride');
    coder.unroll;
    for i=1:numel(strides)
        stride=strides(i);
        coder.internal.assert(coder.const(stride>0&&floor(stride)==stride),...
        'gpucoder:common:StencilfunInvalidStride');
    end
end


function validateInput(input)
    coder.inline('always');
    coder.internal.assert(coder.const(gpucoder.internal.stencil.isSupportedDataType(input)),...
    'gpucoder:common:StencilfunInputUnsupportedType');
end


function paddingValue=validatePaddingValue(paddingValue0,input)
    coder.inline('always');
    if coder.const(isempty(paddingValue0))
        paddingValue=zeros(like=input);
    else
        coder.internal.assert(coder.const(isa(paddingValue0,class(input))&&isscalar(paddingValue0)),...
        'gpucoder:common:StencilfunInvalidPaddingValue');
        if coder.const(coder.target('MATLAB'))
            paddingValue=paddingValue0;
        else
            if coder.const(isreal(input))
                coder.internal.assert(isreal(paddingValue0),...
                'gpucoder:common:StencilfunInvalidPaddingValueComplexity');
                paddingValue=paddingValue0;
            elseif coder.const(isreal(paddingValue0))
                paddingValue=complex(paddingValue0,0);
            else
                paddingValue=paddingValue0;
            end
        end
    end
end


function[negativePaddingAmounts,positivePaddingAmounts]=validateShape(shape0,windowEg)
    coder.inline('always');
    shape=coder.const(validatestring(shape0,{'same','full','valid'},'stencilfun','Shape'));
    numDims=coder.internal.ndims(windowEg);
    negativePaddingAmounts=coder.nullcopy(zeros(numDims,1));
    positivePaddingAmounts=coder.nullcopy(zeros(numDims,1));

    coder.unroll;
    for i=1:numDims
        switch shape
        case 'same'
            negativePaddingAmounts(i)=coder.const(floor((size(windowEg,i)-1)/2));
            positivePaddingAmounts(i)=coder.const(floor(size(windowEg,i)/2));
        case 'full'
            negativePaddingAmounts(i)=coder.const(size(windowEg,i)-1);
            positivePaddingAmounts(i)=coder.const(size(windowEg,i)-1);
        case 'valid'
            negativePaddingAmounts(i)=coder.const(0);
            positivePaddingAmounts(i)=coder.const(0);
        end
    end
    coder.const(negativePaddingAmounts);
    coder.const(positivePaddingAmounts);
end


function newData=resize(data,desiredSize,paddingValue)


    coder.inline('always');
    newData=coder.nullcopy(zeros(coder.const(desiredSize),1));
    coder.unroll;
    for i=1:desiredSize
        if i>numel(data)
            newData(i)=coder.const(paddingValue);
        else
            newData(i)=data(i);
        end
    end
    coder.const(newData);
end


function preprocessOutputEg=validatePreprocessFcn(preprocessFcn,input)
    coder.inline('always');
    coder.internal.assert(coder.const(isa(preprocessFcn,'function_handle')&&nargin(preprocessFcn)==1),...
    'gpucoder:common:StencilfunInvalidPreprocess');

    if coder.const(coder.target('MATLAB'))
        preprocessOutputEg=0;
    else
        inputElemEg=coder.internal.scalarEg(input);
        preprocessOutputEg=coder.internal.gpuDummyCall(preprocessFcn,inputElemEg);
        coder.internal.assert(coder.const(isscalar(preprocessOutputEg)...
        &&gpucoder.internal.stencil.isSupportedDataType(preprocessOutputEg)),...
        'gpucoder:common:StencilfunInvalidPreprocess');
    end
end


function outputEg=getOutputEg(input,windowEg,negativePaddingAmounts,positivePaddingAmounts,strides)
    coder.inline('always');
    numDims=numel(strides);
    outputSize=coder.nullcopy(zeros(1,numDims));
    coder.unroll;
    for dimIdx=1:numDims
        paddedInputDimSize=size(input,dimIdx)+negativePaddingAmounts(dimIdx)+positivePaddingAmounts(dimIdx);
        numerator=max(paddedInputDimSize-size(windowEg,dimIdx)+strides(dimIdx),0);
        outputSize(dimIdx)=idivide(numerator,int32(strides(dimIdx)));
        if coder.internal.isConst(size(input,dimIdx))
            coder.const(outputSize(dimIdx));
        end
    end

    outputEg=coder.nullcopy(false(outputSize));
end


function stencilFcnOutputsEg=validateStencilFcn(stencilFcn,numArgsOut,windowEg,preprocessOutputEg)
    coder.inline('always');
    coder.internal.assert(coder.const(isa(stencilFcn,'function_handle')...
    &&nargin(stencilFcn)>=1),'gpucoder:common:StencilfunInvalidStencil');

    if coder.const(coder.target('MATLAB'))
        stencilFcnOutputsEg={};
    else
        preprocessedWindowEg=coder.nullcopy(zeros(size(windowEg),like=preprocessOutputEg));
        stencilFcnOutputsEg=cell(numArgsOut,1);
        numOutputIdxs=nargin(stencilFcn)-1;
        outputIdxs=cell(numOutputIdxs,1);
        coder.unroll;
        for dimIdx=1:numOutputIdxs
            outputIdxs{dimIdx}=ones('int32');
        end
        [stencilFcnOutputsEg{:}]=coder.internal.gpuDummyCall(stencilFcn,preprocessedWindowEg,outputIdxs{:});

        coder.unroll;
        for i=1:numArgsOut
            out=stencilFcnOutputsEg{i};
            coder.internal.assert(coder.const(isscalar(out)&&...
            gpucoder.internal.stencil.isSupportedDataType(out)),...
            'gpucoder:common:StencilfunInvalidStencil');
        end
    end
end