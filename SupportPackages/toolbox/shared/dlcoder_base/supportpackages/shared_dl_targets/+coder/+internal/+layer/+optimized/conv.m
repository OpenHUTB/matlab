function Z=conv(X,varargin)


























%#codegen



    coder.allowpcode("plain");

    parms={
'Stride'
'Padding'
'Dilation'
'FilterSize'
'NumFilters'
'ConvolutionParameters'
'Weights'
'Bias'
'AreLearnablesReformatted'
'ActivationParams'
'ActivationFunctionType'
    };
    pstruct=coder.internal.parseParameterInputs(parms,[],varargin{:});
    stride=coder.const(coder.internal.getParameterValue(pstruct.Stride,[],varargin{:}));
    padding=coder.const(coder.internal.getParameterValue(pstruct.Padding,[],varargin{:}));
    dilation=coder.const(coder.internal.getParameterValue(pstruct.Dilation,[],varargin{:}));
    filterSize=coder.const(coder.internal.getParameterValue(pstruct.FilterSize,[],varargin{:}));
    numFilters=coder.const(coder.internal.getParameterValue(pstruct.NumFilters,[],varargin{:}));
    convolutionParameters=coder.const(coder.internal.getParameterValue(pstruct.ConvolutionParameters,[],varargin{:}));
    areLearnablesReformatted=coder.const(coder.internal.getParameterValue(pstruct.AreLearnablesReformatted,...
    false,varargin{:}));

    weights=coder.internal.getParameterValue(pstruct.Weights,[],varargin{:});
    bias=coder.internal.getParameterValue(pstruct.Bias,[],varargin{:});
    activationParams=coder.internal.getParameterValue(pstruct.ActivationParams,struct,varargin{:});
    activationFunctionType=coder.internal.getParameterValue(pstruct.ActivationFunctionType,'',varargin{:});


    coder.internal.assert(~isempty(stride),...
    "Coder:builtins:Explicit","stride not specified");
    coder.internal.assert(~isempty(dilation),...
    "Coder:builtins:Explicit","dilation not specified");
    coder.internal.assert(~isempty(padding),...
    "Coder:builtins:Explicit","padding not specified");
    coder.internal.assert(~isempty(filterSize),...
    "Coder:builtins:Explicit","filterSize not specified");
    coder.internal.assert(~isempty(numFilters),...
    "Coder:builtins:Explicit","numFilters not specified");
    coder.internal.assert(~isempty(convolutionParameters),...
    "Coder:builtins:Explicit","convolution parameters not specified");
    coder.internal.assert(~isempty(weights),...
    "Coder:builtins:Explicit","weights not specified");
    coder.internal.assert(~isempty(bias),...
    "Coder:builtins:Explicit","bias not specified");


    if coder.target("MEX")
        coder.internal.assert(convolutionParameters.SimdWidth==1,"Coder:builtins:Explicit",...
        "SIMD vector length must be 1 for MEX targets");
    end

    inputHeight=size(X,1);
    inputWidth=size(X,2);
    inputChannels=size(X,3);
    numImages=size(X,4);
    kernelHeight=filterSize(1);
    kernelWidth=filterSize(2);
    outputChannels=numFilters;

    strideVert=stride(1);
    strideHorz=stride(2);
    dilationVert=dilation(1);
    dilationHorz=dilation(2);
    paddingT=padding(1);
    paddingB=padding(2);
    paddingL=padding(3);
    paddingR=padding(4);

    [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=...
    coder.internal.layer.convUtils.computeOutputSize(X,filterSize,numFilters,...
    padding,stride,dilation);
    Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],"like",X));

    if coder.const(coder.internal.isConst(bias))
        hasBias=any(bias~=0);
    else


        hasBias=true;
    end



    useMultiThreading=coder.const(coder.internal.coderNetworkUtils.canUseMultiThreading())&&...
    coder.const(convolutionParameters.AllowMultiThreading);

    if coder.const(~areLearnablesReformatted)

        coder.internal.assert(size(bias,3)==outputChannels,...
        "Coder:builtins:Explicit","dimension mismatch");
        coder.internal.assert(size(weights,3)==inputChannels,...
        "Coder:builtins:Explicit","dimension mismatch");

        [weightsReformatted,biasReformatted]=coder.const(@feval,...
        'coder.internal.layer.optimized.convReformatWeights',...
        weights,bias,convolutionParameters.InputChannelMiniblockSize,...
        convolutionParameters.SimdWidth);

    else

        weightsReformatted=weights;
        biasReformatted=bias;

    end

    coder.extrinsic('coder.internal.layer.utils.getActivationEnum');
    activationEnum=coder.const(coder.internal.layer.utils.getActivationEnum(activationFunctionType));

    coder.extrinsic('coder.internal.layer.utils.packageActivationParamsForCgirFusion');
    packagedActivationParams=coder.const(...
    coder.internal.layer.utils.packageActivationParamsForCgirFusion(...
    activationFunctionType,activationParams));

    coder.ceval("#__convolution_anchor",...
    coder.rref(X),coder.wref(Z),coder.rref(weightsReformatted),coder.rref(biasReformatted),...
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
    coder.const(toInt(convolutionParameters.SimdWidth)),...
    coder.const(toInt(convolutionParameters.InputChannelBlockSize)),...
    coder.const(toInt(convolutionParameters.InputChannelMiniblockSize)),...
    coder.const(toInt(convolutionParameters.OutputChannelBlockSize)),...
    coder.const(toInt(convolutionParameters.OutputHeightBlockSize)),...
    coder.const(toInt(convolutionParameters.MaxMinIntrinsic)),...
    coder.const(useMultiThreading),...
    coder.const(toInt(coder.const(activationEnum))),...
    coder.internal.valuelistfun(@coder.const,packagedActivationParams)...
    );

end

function v=toInt(x)
    v=coder.internal.indexInt(x);
end
