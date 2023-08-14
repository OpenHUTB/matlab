function varargout=forGpuCodegen(stencilFcn,input,outputEg,windowEg,negativePaddingAmounts,...
    positivePaddingAmounts,strides,paddingValue,preprocessFcn,tileSize,useSharedInputBuffer,...
    skipCallbackChecks)
%#codegen



    coder.allowpcode('plain');


    coder.inline('never');
    coder.internal.cfunctionname('#__stencilKernel__');

    coder.ceval('-layout:any','#__stencilKernel_input__',coder.rref(input));
    coder.ceval('#__stencilKernel_row_major__',coder.const(coder.isRowMajor));
    coder.ceval('#__stencilKernel_batch_size__',coder.const(coder.internal.indexInt(nargout)));
    coder.ceval('#__stencilKernel_padding_value__',paddingValue);
    intArrayAnchor('#__stencilKernel_negative_padding__',negativePaddingAmounts);
    intArrayAnchor('#__stencilKernel_positive_padding__',positivePaddingAmounts);
    intArrayAnchor('#__stencilKernel_strides__',strides);
    intArrayAnchor('#__stencilKernel_tile_size__',tileSize);
    coder.ceval('#__stencilKernel_use_shared_input_buffer__',coder.const(useSharedInputBuffer));
    coder.ceval('#__stencilKernel_skip_callback_checks__',coder.const(skipCallbackChecks));

    preprocessInputEg=coder.internal.scalarEg(input);
    preprocessOutputEg=preprocessFcnWrapper(preprocessFcn,preprocessInputEg);
    windowEg2=coder.nullcopy(zeros(size(windowEg),like=preprocessOutputEg));
    numOutputIdxs=nargin(stencilFcn)-1;
    outputIdxsEg=cell(numOutputIdxs,1);
    coder.unroll;
    for dimIdx=1:numOutputIdxs
        outputIdxsEg{dimIdx}=zeros('int32');
        coder.ceval('#__stencilKernel_dummy__',coder.ref(outputIdxsEg{dimIdx}));
    end
    funcOutputsEg=cell(nargout,1);
    [funcOutputsEg{:}]=funcWrapper(stencilFcn,windowEg2,outputIdxsEg{:});

    coder.unroll;
    for i=1:nargout
        varargout{i}=getDummyOutput(outputEg,funcOutputsEg{i});
    end
end


function intArrayAnchor(name,values)
    coder.inline('always');
    C=cell(numel(values),1);
    coder.unroll
    for i=1:numel(values)
        C{i}=values(i);
    end

    if coder.const(isempty(C))
        coder.ceval(coder.const(name));
    else
        coder.ceval(coder.const(name),...
        coder.internal.valuelistfun(@(x)coder.const(coder.internal.indexInt(x)),C));
    end
end


function output=preprocessFcnWrapper(preprocessFcn,input)
    coder.inline('never');
    coder.internal.cfunctionname('#__stencilKernel_preprocess_wrapper__');
    coder.ceval('#__stencilKernel_dummy__',coder.ref(input));
    output=preprocessFcn(input);
    coder.ceval('#__stencilKernel_dummy__',coder.ref(output));
end


function varargout=funcWrapper(func,windowEg,varargin)
    coder.inline('never');
    coder.internal.cfunctionname('#__stencilKernel_stencil_fcn_wrapper__');
    coder.ceval('-layout:any','-preservearraydims','#__stencilKernel_window__',coder.ref(windowEg));








    outputIdxs=cell(numel(varargin)+1,1);
    coder.unroll;
    for dimIdx=1:numel(varargin)
        outputIdxs{dimIdx}=varargin{dimIdx};
        coder.ceval('#__stencilKernel_output_idx__',coder.const(int32(dimIdx)-1),coder.rref(outputIdxs{dimIdx}));
    end
    [varargout{:}]=func(windowEg,varargin{:});
    tmpCell=cell(nargout,1);
    coder.unroll;
    for i=1:nargout
        tmpCell{i}=varargout{i};
        coder.ceval('#__stencilKernel_dummy__',coder.ref(tmpCell{i}));
        varargout{i}=tmpCell{i};
    end
end


function dummyOutput=getDummyOutput(outputEg,funcOutputEg)
    coder.inline('always');
    dummyOutput=coder.nullcopy(zeros(size(outputEg),like=funcOutputEg));
    coder.ceval('-layout:any','#__stencilKernel_output_lhs__',coder.wref(dummyOutput));
end
