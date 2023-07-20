function outputTensor=cudaImplicitGemmConv(X,varargin)






























































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
'WarpOutputTileHeight'
'WarpOutputTileWidth'
'WorkGroupOutputTileHeight'
'WorkGroupOutputTileWidth'
'NumInnerDimTiles'
'InnerDimUnrollFactor'
'SimdLength'
'UsePrefetching'
'UseDoubleBuffering'
'MinBlocksPerSM'
'SharedMemoryPaddingA'
'SharedMemoryPaddingB'
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
    warpOutputTileHeight=coder.internal.getParameterValue(...
    pstruct.WarpOutputTileHeight,[],varargin{:});
    warpOutputTileWidth=coder.internal.getParameterValue(...
    pstruct.WarpOutputTileWidth,[],varargin{:});
    workGroupOutputTileHeight=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputTileHeight,[],varargin{:});
    workGroupOutputTileWidth=coder.internal.getParameterValue(...
    pstruct.WorkGroupOutputTileWidth,[],varargin{:});
    numInnerDimTiles=coder.internal.getParameterValue(...
    pstruct.NumInnerDimTiles,[],varargin{:});
    innerDimUnrollFactor=coder.internal.getParameterValue(...
    pstruct.InnerDimUnrollFactor,[],varargin{:});
    simdLength=coder.internal.getParameterValue(...
    pstruct.SimdLength,[],varargin{:});
    usePrefetching=coder.internal.getParameterValue(...
    pstruct.UsePrefetching,[],varargin{:});
    useDoubleBuffering=coder.internal.getParameterValue(...
    pstruct.UseDoubleBuffering,[],varargin{:});
    minBlocksPerSM=coder.internal.getParameterValue(...
    pstruct.MinBlocksPerSM,[],varargin{:});
    sharedMemoryPaddingA=coder.internal.getParameterValue(...
    pstruct.SharedMemoryPaddingA,[],varargin{:});
    sharedMemoryPaddingB=coder.internal.getParameterValue(...
    pstruct.SharedMemoryPaddingB,[],varargin{:});

    checkValidAttributes(stride,"stride");
    checkValidAttributes(dilation,"dilation");
    checkValidAttributes(padding,"padding");
    checkValidAttributes(weights,"weights");
    checkValidAttributes(bias,"bias");
    checkValidAttributes(workItemOutputTileHeight,"workItemOutputTileHeight",CheckPositive=true);
    checkValidAttributes(workItemOutputTileWidth,"workItemOutputTileWidth",CheckPositive=true);
    checkValidAttributes(warpOutputTileHeight,"warpOutputTileHeight",CheckPositive=true);
    checkValidAttributes(warpOutputTileWidth,"warpOutputTileWidth",CheckPositive=true);
    checkValidAttributes(workGroupOutputTileHeight,"workGroupOutputTileHeight",CheckPositive=true);
    checkValidAttributes(workGroupOutputTileWidth,"workGroupOutputTileWidth",CheckPositive=true);
    checkValidAttributes(numInnerDimTiles,"numInnerDimTiles",CheckPositive=true);
    checkValidAttributes(innerDimUnrollFactor,"innerDimUnrollFactor",CheckPositive=true);
    checkValidAttributes(simdLength,"simdLength",CheckPositive=true);
    checkValidAttributes(usePrefetching,"usePrefetching",CheckLogical=true);
    checkValidAttributes(useDoubleBuffering,"useDoubleBuffering",CheckLogical=true);
    checkValidAttributes(minBlocksPerSM,"minBlocksPerSM",CheckPositive=true);
    checkValidAttributes(sharedMemoryPaddingA,"sharedMemoryPaddingA");
    checkValidAttributes(sharedMemoryPaddingB,"sharedMemoryPaddingB");

    inputHeight=size(X,1);
    inputWidth=size(X,2);
    inputChannels=size(X,3);
    numImages=size(X,4);
    kernelHeight=size(weights,1);
    kernelWidth=size(weights,2);
    outputChannels=size(weights,4);

    coder.internal.assert(isSingle(X)&&isSingle(weights)&&isSingle(bias),...
    "Coder:builtins:Explicit","Input, weights and bias must be single type");

    coder.internal.assert(size(bias,3)==outputChannels,...
    "Coder:builtins:Explicit","dimension mismatch");
    coder.internal.assert(size(weights,3)==inputChannels,...
    "Coder:builtins:Explicit","dimension mismatch");
    if coder.const(((warpOutputTileHeight/workItemOutputTileHeight)*...
        (warpOutputTileWidth/workItemOutputTileWidth)~=32))
        coder.internal.assert(false,"Coder:builtins:Explicit","There can be only 32 threads in a warp");
    end

    if coder.const((~iIsFactor(simdLength,sharedMemoryPaddingA)||~iIsFactor(simdLength,sharedMemoryPaddingB)))
        coder.internl.assert(false,"Coder:builtins:Explicit","Shared memory padding size must be a multiple of SIMD length");
    end

    if coder.const((simdLength~=1&&simdLength~=2&&simdLength~=4))
        coder.internal.assert(false,"Coder:builtins:Explicit","For CUDA code generation, SIMD length parameter must be 1, 2 or 4.")
    end

    if coder.const((~iIsFactor(simdLength,workItemOutputTileHeight)||~iIsFactor(simdLength,workItemOutputTileWidth)))
        coder.internal.assert(false,"Coder:builtins:Explicit","Work item output tile size must be a multiple of SIMD length");
    end

    if coder.const(~iIsFactor(workItemOutputTileHeight,warpOutputTileHeight)||~iIsFactor(workItemOutputTileWidth,warpOutputTileWidth))
        coder.internal.assert(false,"Coder:builtins:Explicit","Warp output tile size must be a multiple of work item tile size");
    end

    if coder.const(~iIsFactor(warpOutputTileHeight,workGroupOutputTileHeight)||~iIsFactor(warpOutputTileWidth,workGroupOutputTileWidth))
        coder.internal.assert(false,"Coder:builtins:Explicit","Work group output tile size must be a multiple of warp output tile size");
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
    coder.internal.layer.convUtils.computeOutputSize(X,coder.const(filterSize),coder.const(numFilters),...
    coder.const(padding),coder.const(stride),coder.const(dilation));

    hasBias=true;

    outputTensor=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],"like",X));


    [formattedWeights,formattedBias]=coder.const(@feval,"coder.internal.layer.optimized.cudaImplicitGemmConvReformatWeights",...
    weights,bias,simdLength);


    coder.ceval('-layout:columnMajor',"#__cuda_implicit_gemm_convolution_anchor",...
    coder.rref(X,'gpu'),...
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
    coder.const(toInt(warpOutputTileHeight)),...
    coder.const(toInt(warpOutputTileWidth)),...
    coder.const(toInt(workGroupOutputTileHeight)),...
    coder.const(toInt(workGroupOutputTileWidth)),...
    coder.const(toInt(numInnerDimTiles)),...
    coder.const(toInt(innerDimUnrollFactor)),...
    coder.const(toInt(simdLength)),...
    coder.const(usePrefetching),...
    coder.const(useDoubleBuffering),...
    coder.const(toInt(minBlocksPerSM)),...
    coder.const(toInt(sharedMemoryPaddingA)),...
    coder.const(toInt(sharedMemoryPaddingB))...
    );

end

function v=toInt(x)
    v=coder.internal.indexInt(x);
end


function checkValidAttributes(x,param,varargin)
    coder.internal.prefer_const(x,param)

    params=struct('CheckPositive',false,...
    'CheckLogical',false);

    pstruct=coder.internal.parseParameterInputs(params,[],varargin{:});

    checkPositive=coder.internal.getParameterValue(pstruct.CheckPositive,[],varargin{:});
    checkLogical=coder.internal.getParameterValue(pstruct.CheckLogical,[],varargin{:});

    coder.inline("always");
    coder.internal.assert(~isempty(x),"Coder:builtins:Explicit",...
    "unspecified parameter: "+param);

    if checkPositive
        coder.internal.assert(coder.const(x>0),"Coder:builtins:Explicit",...
        param+" Must be positive");
    end

    if checkLogical
        coder.internal.assert(islogical(x),"Coder:builtins:Explicit",...
        param+" Must be logical type");
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
