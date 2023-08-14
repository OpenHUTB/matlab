function varargout=stencilfun(varargin)






















































































%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    if coder.const(nargout==0)
        numArgsOut=1;
    else
        numArgsOut=nargout;
    end

    if coder.const(coder.target('MATLAB'))
        varargout=cell(numArgsOut,1);
        try %#ok Suppress complaint about try / catch not supported for codegen
            [varargout{:}]=stencilfunHelper(numArgsOut,varargin{:});
        catch e
            throwAsCaller(e);
        end
    else
        [varargout{:}]=stencilfunHelper(numArgsOut,varargin{:});
    end
end


function varargout=stencilfunHelper(numArgsOut,stencilFcn,input,windowSize0,varargin)
    coder.inline('always');

    [preprocessFcn,strides,tileSize,useSharedInputBuffer,windowEg,paddingValue,negativePaddingAmounts,...
    positivePaddingAmounts,preprocessOutputEg,stencilFcnOutputsEg,outputEg,skipCallbackChecks]=...
    gpucoder.internal.stencil.validate(stencilFcn,input,windowSize0,numArgsOut,varargin{:});

    fallbackToSimImpl=coder.internal.targetLang('cuda')&&~coder.internal.isConst(size(input));
    useSimImpl=coder.target('MATLAB')||~coder.internal.targetLang('cuda')||fallbackToSimImpl;

    if coder.const(useSimImpl)
        if coder.const(fallbackToSimImpl)
            coder.internal.compileWarning('gpucoder:common:StencilfunVarsizedInputFallback');
        end
        if coder.const(coder.target('MATLAB'))
            varargout=cell(numArgsOut,1);
        end
        [varargout{:}]=gpucoder.internal.stencil.forSim(stencilFcn,input,outputEg,windowEg,...
        negativePaddingAmounts,positivePaddingAmounts,strides,paddingValue,preprocessFcn,...
        preprocessOutputEg,stencilFcnOutputsEg);
    else
        [varargout{:}]=gpucoder.internal.stencil.forGpuCodegen(stencilFcn,input,outputEg,windowEg,...
        negativePaddingAmounts,positivePaddingAmounts,strides,paddingValue,preprocessFcn,...
        tileSize,useSharedInputBuffer,skipCallbackChecks);
    end
end
