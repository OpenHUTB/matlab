function varargout=forSim(stencilFcn,input,outputEg,windowEg,negativePaddingAmounts,positivePaddingAmounts,...
    strides,paddingValue,preprocessFcn,preprocessOutputEg,stencilFcnOutputsEg)
%#codegen



    coder.allowpcode('plain');

    if coder.const(coder.target('MATLAB'))
        varargout=cell(1,nargout);
    end
    coder.unroll;
    for i=1:nargout




        if coder.const(~coder.target('MATLAB'))
            varargout{i}=coder.nullcopy(zeros(size(outputEg),like=stencilFcnOutputsEg{i}));
        end
    end
    numDims=numel(strides);
    preprocessedInput=preprocessInput(input,negativePaddingAmounts,positivePaddingAmounts,...
    strides,paddingValue,preprocessFcn,preprocessOutputEg);
    outputIdxs=cell(max(numDims,nargin(stencilFcn)-1),1);
    outputIdxs2=cell(nargin(stencilFcn)-1,1);
    outputValues=cell(nargout,1);
    for linearIdx=1:numel(outputEg)
        [outputIdxs{:}]=ind2sub(size(outputEg),linearIdx);
        window=getWindow(windowEg,strides,outputIdxs,preprocessedInput);
        coder.unroll;
        for dimIdx=1:numel(outputIdxs2)
            outputIdxs2{dimIdx}=int32(outputIdxs{dimIdx});
        end
        [outputValues{:}]=stencilFcn(window,outputIdxs2{:});
        coder.unroll;
        for i=1:nargout
            if coder.const(coder.target('MATLAB'))
                if linearIdx==1
                    validateOutputElement(outputValues{i});
                    varargout{i}=zeros(size(outputEg),like=outputValues{i});
                else
                    coder.internal.assert(isa(outputValues{i},class(varargout{i})),...
                    'gpucoder:common:StencilfunInconsistentOutputTypes');
                end
            end
            varargout{i}(linearIdx)=outputValues{i};
        end
    end
end


function preprocessedInput=preprocessInput(input,negativePaddingAmounts,positivePaddingAmounts,...
    strides,paddingValue,preprocessFcn,preprocessOutputEg)

    coder.inline('always');
    numDims=numel(strides);
    dimSizes=coder.nullcopy(zeros(1,numDims));
    idxs=cell(1,numDims);
    coder.unroll;
    for dimIdx=1:numDims
        dimSizes(dimIdx)=size(input,dimIdx)+negativePaddingAmounts(dimIdx)+positivePaddingAmounts(dimIdx);
        idxs{dimIdx}=negativePaddingAmounts(dimIdx)+(1:size(input,dimIdx));
    end
    expandedInput=repmat(paddingValue,dimSizes);
    expandedInput(idxs{:})=input;


    if coder.const(~coder.target('MATLAB'))
        preprocessedInput=coder.nullcopy(zeros(size(expandedInput),like=preprocessOutputEg));
    end
    for linearIdx=1:numel(expandedInput)
        preprocessedElem=preprocessFcn(expandedInput(linearIdx));
        if coder.const(coder.target('MATLAB'))
            if linearIdx==1
                validatePreprocessElement(preprocessedElem);
                preprocessedInput=zeros(size(expandedInput),like=preprocessedElem);
            else
                coder.internal.assert(isa(preprocessedElem,class(preprocessedInput)),...
                'gpucoder:common:StencilfunInconsistentPreprocessTypes');
            end
        end
        preprocessedInput(linearIdx)=preprocessedElem;
    end
end


function window=getWindow(windowEg,strides,outputIdxs,preprocessedInput)
    coder.inline('always');
    numDims=numel(strides);
    inputIdxs=cell(numDims,1);
    coder.unroll;
    for dimIdx=1:numDims
        inputIdxs{dimIdx}=strides(dimIdx)*(outputIdxs{dimIdx}-1)+(1:size(windowEg,dimIdx));
    end
    window=preprocessedInput(inputIdxs{:});
end


function validatePreprocessElement(x)
    coder.internal.assert(isscalar(x)&&gpucoder.internal.stencil.isSupportedDataType(x),...
    'gpucoder:common:StencilfunInvalidPreprocess');
end


function validateOutputElement(x)
    coder.internal.assert(isscalar(x)&&gpucoder.internal.stencil.isSupportedDataType(x),...
    'gpucoder:common:StencilfunInvalidStencil');
end
