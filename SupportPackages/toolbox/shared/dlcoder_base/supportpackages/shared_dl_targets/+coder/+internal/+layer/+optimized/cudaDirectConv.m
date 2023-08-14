function outputTensor=cudaDirectConv(inputTensor,varargin)


























































%#codegen



    coder.allowpcode("plain");
    coder.inline("always");

    parms={
'Stride'
'Padding'
'Dilation'
'Weights'
'Bias'
'WorkItemOutputTileHeight'
'WorkItemOutputTileWidth'
'WorkItemOutputTileChannels'
'WorkItemTileBatches'
'WorkGroupOutputTileHeight'
'WorkGroupOutputTileWidth'
'WorkGroupOutputTileChannels'
'WorkGroupTileBatches'
'NumInputChannelTiles'
'UseStridedThreadTiles'
'SimdLength'
'MinBlocksPerSM'
    };
    pstruct=coder.internal.parseParameterInputs(parms,[],varargin{:});

    stride=coder.internal.getParameterValue(pstruct.Stride,[],varargin{:});
    padding=coder.internal.getParameterValue(pstruct.Padding,[],varargin{:});
    dilation=coder.internal.getParameterValue(pstruct.Dilation,[],varargin{:});
    weights=coder.internal.getParameterValue(pstruct.Weights,[],varargin{:});
    bias=coder.internal.getParameterValue(pstruct.Bias,[],varargin{:});
    workItemOutputTileHeight=coder.internal.getParameterValue(...
    pstruct.WorkItemOutputTileHeight,[],varargin{:});

    workItemOutputTileWidth=coder.internal.getParameterValue(...
    pstruct.WorkItemOutputTileWidth,[],varargin{:});

    workItemOutputTileChannels=coder.internal.getParameterValue(...
    pstruct.WorkItemOutputTileChannels,[],varargin{:});

    workItemTileBatches=coder.internal.getParameterValue(...
    pstruct.WorkItemTileBatches,[],varargin{:});

    workGroupOutputTileHeight=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputTileHeight,[],varargin{:});

    workGroupOutputTileWidth=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputTileWidth,[],varargin{:});

    workGroupOutputTileChannels=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputTileChannels,[],varargin{:});

    workGroupTileBatches=coder.internal.getParameterValue(...
    pstruct.WorkGroupTileBatches,[],varargin{:});

    numInputChannelTiles=coder.internal.getParameterValue(...
    pstruct.NumInputChannelTiles,[],varargin{:});
    useStridedThreadTiles=coder.internal.getParameterValue(...
    pstruct.UseStridedThreadTiles,[],varargin{:});
    simdLength=coder.internal.getParameterValue(...
    pstruct.SimdLength,[],varargin{:});
    minBlocksPerMultiprocessor=coder.internal.getParameterValue(...
    pstruct.MinBlocksPerSM,[],varargin{:});

    checkValidAttributes(stride,"stride");
    checkValidAttributes(dilation,"dilation");
    checkValidAttributes(padding,"padding");
    checkValidAttributes(weights,"weights");
    checkValidAttributes(bias,"bias");
    checkValidAttributes(workItemOutputTileHeight,"workItemOutputTileHeight",CheckPositive=true);
    checkValidAttributes(workItemOutputTileWidth,"workItemOutputTileWidth",CheckPositive=true);
    checkValidAttributes(workItemOutputTileChannels,"workItemOutputTileChannels",CheckPositive=true);
    checkValidAttributes(workItemTileBatches,"workItemTileBatches",CheckPositive=true);
    checkValidAttributes(workGroupOutputTileHeight,"workGroupOutputTileHeight",CheckPositive=true);
    checkValidAttributes(workGroupOutputTileWidth,"workGroupOutputTileWidth",CheckPositive=true);
    checkValidAttributes(workGroupOutputTileChannels,"workGroupOutputTileChannels",CheckPositive=true);
    checkValidAttributes(workGroupTileBatches,"workGroupTileBatches",CheckPositive=true);
    checkValidAttributes(numInputChannelTiles,"numInputChannelTiles",CheckPositive=true);
    checkValidAttributes(useStridedThreadTiles,"useStridedThreadTiles",CheckLogical=true);
    checkValidAttributes(simdLength,"simdLength",CheckPositive=true);
    checkValidAttributes(minBlocksPerMultiprocessor,"minBlocksPerMultiprocessor",CheckPositive=true);

    inputHeight=size(inputTensor,1);
    inputWidth=size(inputTensor,2);
    inputChannels=size(inputTensor,3);
    numImages=size(inputTensor,4);
    kernelHeight=size(weights,1);
    kernelWidth=size(weights,2);
    outputChannels=size(weights,4);

    coder.internal.assert(isSingle(inputTensor)&&isSingle(weights)&&isSingle(bias),...
    "Coder:builtins:Explicit","Input, weights and bias must be single type");

    coder.internal.assert(size(bias,3)==outputChannels,...
    "Coder:builtins:Explicit","dimension mismatch");
    coder.internal.assert(size(weights,3)==inputChannels,...
    "Coder:builtins:Explicit","dimension mismatch");

    if coder.const((simdLength~=1&&simdLength~=2&&simdLength~=4))
        coder.internal.assert(false,"Coder:builtins:Explicit","For CUDA code generation, SIMD length parameter must be 1, 2 or 4.")
    end

    if coder.const(~iIsFactor(simdLength,workItemOutputTileChannels))
        coder.internal.assert(false,"Coder:builtins:Explicit","Work item output channel tile size must be a multiple of SIMD length");
    end

    if coder.const(~iIsFactor(workItemOutputTileHeight,workGroupOutputTileHeight)...
        ||~iIsFactor(workItemOutputTileWidth,workGroupOutputTileWidth)...
        ||~iIsFactor(workItemOutputTileChannels,workGroupOutputTileChannels)...
        ||~iIsFactor(workItemTileBatches,workGroupTileBatches))
        coder.internal.assert(false,"Coder:builtins:Explicit","Work group output tile size must be a multiple of work item output tile size");
    end

    strideVert=stride(1);
    strideHorz=stride(2);
    dilationVert=dilation(1);
    dilationHorz=dilation(2);
    paddingT=padding(1);
    paddingB=padding(2);
    paddingL=padding(3);
    paddingR=padding(4);
    filterSize=size(weights,1:2);
    numFilters=size(weights,4);

    [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=...
    coder.internal.layer.convUtils.computeOutputSize(inputTensor,coder.const(filterSize),coder.const(numFilters),...
    coder.const(padding),coder.const(stride),coder.const(dilation));


    hasBias=true;

    outputTensor=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],"like",inputTensor));

    [formattedWeights,formattedBias]=coder.const(@feval,"coder.internal.layer.optimized.cudaDirectConvReformatWeights",...
    weights,bias,simdLength);


    coder.ceval('-layout:columnMajor',"#__cuda_direct_convolution_anchor",...
    coder.rref(inputTensor,'gpu'),...
    coder.ref(outputTensor,'gpu'),...
    coder.rref(formattedWeights,'gpu'),...
    coder.rref(formattedBias,'gpu'),...
    coder.const(toInt(inputHeight)),...
    coder.const(toInt(inputWidth)),...
    coder.const(toInt(inputChannels)),...
    coder.const(toInt(outputChannels)),...
    coder.const(toInt(numImages)),...
    coder.const(toInt(kernelHeight)),...
    coder.const(toInt(kernelWidth)),...
    coder.const(toInt(strideVert)),...
    coder.const(toInt(strideHorz)),...
    coder.const(toInt(dilationVert)),...
    coder.const(toInt(dilationHorz)),...
    coder.const(toInt(paddingT)),...
    coder.const(toInt(paddingB)),...
    coder.const(toInt(paddingL)),...
    coder.const(toInt(paddingR)),...
    coder.const(hasBias),...
    coder.const(toInt(workItemOutputTileHeight)),...
    coder.const(toInt(workItemOutputTileWidth)),...
    coder.const(toInt(workItemOutputTileChannels)),...
    coder.const(toInt(workItemTileBatches)),...
    coder.const(toInt(workGroupOutputTileHeight)),...
    coder.const(toInt(workGroupOutputTileWidth)),...
    coder.const(toInt(workGroupOutputTileChannels)),...
    coder.const(toInt(workGroupTileBatches)),...
    coder.const(toInt(numInputChannelTiles)),...
    coder.const(useStridedThreadTiles),...
    coder.const(toInt(simdLength)),...
    coder.const(toInt(minBlocksPerMultiprocessor))...
    );

end



function v=toInt(x)
    coder.inline("always");
    v=coder.internal.indexInt(x);
end


function checkValidAttributes(x,paramName,varargin)
    coder.internal.prefer_const(x,paramName)
    coder.inline('always')

    params=struct('CheckPositive',false,...
    'CheckLogical',false);

    pstruct=coder.internal.parseParameterInputs(params,[],varargin{:});

    checkPositive=coder.internal.getParameterValue(pstruct.CheckPositive,[],varargin{:});
    checkLogical=coder.internal.getParameterValue(pstruct.CheckLogical,[],varargin{:});

    coder.internal.assert(~isempty(x),"Coder:builtins:Explicit",...
    "unspecified parameter: "+paramName);

    if checkPositive
        coder.internal.assert(coder.const(x>0),"Coder:builtins:Explicit",...
        paramName+" must be positive");
    end

    if checkLogical
        coder.internal.assert(islogical(x),"Coder:builtins:Explicit",...
        paramName+" must be logical type");
    end

end

function tf=iIsFactor(a,b)
    coder.internal.prefer_const(a,b);
    coder.inline('always');
    tf=coder.const(mod(b,a)==0);
end

function tf=isSingle(a)
    coder.inline('always');
    tf=coder.const(isa(a,'single'));
end
