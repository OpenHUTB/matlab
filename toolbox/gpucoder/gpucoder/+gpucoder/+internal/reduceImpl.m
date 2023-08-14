function varargout=reduceImpl(inputArray,funcArray,numout,varargin)




%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);
    narginchk(3,inf);


    coder.internal.assert(~iscell(inputArray),'gpucoder:common:GpucoderReduceCellUnsupported');


    if coder.target('MATLAB')

        coder.internal.assert(isa(inputArray,'gpuArray')||coder.internal.isBuiltInNumeric(inputArray)||...
        islogical(inputArray),'gpucoder:common:GpucoderReduceUnsupportedType');
    else

        coder.internal.assert(coder.internal.isBuiltInNumeric(inputArray)||islogical(inputArray),...
        'gpucoder:common:GpucoderReduceUnsupportedType');
    end


    coder.internal.assert(isreal(inputArray),'gpucoder:common:GpucoderReduceComplexInputs');


    coder.internal.assert(~issparse(inputArray),'gpucoder:common:GpucoderReduceSparseInputs');



    coder.internal.assert((iscell(funcArray)&&isrow(funcArray))||isa(funcArray,'function_handle'),...
    'gpucoder:common:GpucoderReduceFuncHandleInput');

    if iscell(funcArray)
        newFuncArray=funcArray;
    else
        newFuncArray={funcArray};
    end

    ONE=coder.internal.indexInt(1);
    numFunctions=coder.const(coder.internal.indexInt(length(newFuncArray)));


    for i=ONE:numFunctions

        coder.internal.assert(isa(newFuncArray{i},'function_handle'),...
        'gpucoder:common:GpucoderReduceFuncHandleInput');


        coder.internal.assert(~startsWith(func2str(newFuncArray{i}),'@'),...
        'gpucoder:common:GpucoderReduceAnonymousFuncHandle');


        coder.internal.assert(nargin(newFuncArray{i})==2&&nargout(newFuncArray{i})==1,...
        'gpucoder:common:GpucoderReduceFuncHandleInvalid',func2str(newFuncArray{i}));


        if~isempty(inputArray)
            t=newFuncArray{i}(inputArray(ONE),inputArray(ONE));
            coder.internal.assert(isa(t,class(inputArray)),...
            'gpucoder:common:GpucoderReduceFuncHandleInvalid',func2str(newFuncArray{i}));
        end
    end

    [dimArg,preproArg,pstruct]=gpucoder.internal.parseReduceOptionalParams(varargin{:});
    optionalParamCount=coder.internal.indexInt(0);
    if~isequal(pstruct.dim,0)
        coder.internal.assertValidDim(dimArg);
        coder.internal.assert(coder.internal.isConst(dimArg),'Coder:toolbox:dimNotConst');
        redDim=coder.internal.indexInt(dimArg);
        optionalParamCount=optionalParamCount+1;
    else
        redDim=coder.internal.indexInt([]);
    end

    if~isequal(pstruct.preprocess,0)
        coder.internal.assert(isa(preproArg,'function_handle'),'gpucoder:common:GpucoderReduceExpectedPrepro');
        preProcessingFcn=preproArg;
        optionalParamCount=optionalParamCount+1;

        coder.internal.assert(nargin(preProcessingFcn)==1,'gpucoder:common:GpucoderReduceInvalidPreprocessFcn');
    else
        if coder.target('MATLAB')
            preProcessingFcn=[];
        else
            preProcessingFcn=@identityFcn;
        end
    end


    nv=coder.internal.indexInt(nargin-3-optionalParamCount*2);
    coder.internal.assert(nv==0,'gpucoder:common:GpucoderIncorrectNumArgs','gpucoder.reduce');


    coder.internal.assert(numout<=numFunctions,'MATLAB:nargoutchk:tooManyOutputs');


    numDims=coder.internal.ndims(inputArray);
    if~isempty(redDim)&&redDim>numDims
        coder.internal.assert(false,'gpucoder:common:GpucoderReduceDimensionTooLarge');
    end

    if~coder.target('MATLAB')&&~isempty(inputArray)
        coder.internal.assert(~coder.internal.isConst(preProcessingFcn(inputArray(1))),'gpucoder:common:GpucoderReducePreprocessConst',func2str(preProcessingFcn));
        for l=ONE:numFunctions
            tmp=newFuncArray{l};
            coder.internal.assert(~coder.internal.isConst(tmp(inputArray(1),inputArray(1))),'gpucoder:common:GpucoderReduceFuncHandleConst',func2str(tmp));
        end
    end

    if coder.target('MATLAB')
        [varargout{1:numout}]=gpucoder.internal.reduce_sim(inputArray,newFuncArray,redDim,preProcessingFcn);
    else
        if coder.gpu.internal.isGpuReduceSupported()
            if isempty(redDim)
                if numout==1
                    [varargout{1:numout}]=gpucoder.internal.reduce_codegen(inputArray,newFuncArray,preProcessingFcn);
                else
                    outp=gpucoder.internal.reduce_codegen(inputArray,newFuncArray,preProcessingFcn);
                    for l=ONE:numout
                        varargout{l}=outp(l);
                    end
                end
            elseif numel(inputArray)==size(inputArray,redDim)
                outp=gpucoder.internal.reduce_codegen(inputArray,newFuncArray,preProcessingFcn);
                for l=ONE:numout
                    varargout{l}=outp(l);
                end
            else
                [varargout{1:numout}]=gpucoder.internal.reduce_codegen_dim(inputArray,newFuncArray,redDim,preProcessingFcn);
            end
        else
            [varargout{1:numout}]=gpucoder.internal.reduce_sim(inputArray,newFuncArray,redDim,preProcessingFcn);
        end
    end

end

function output=identityFcn(input)
    output=input;
end
