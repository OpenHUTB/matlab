function[alpha,beta,transA,transB]=parseStridedBatchedOptionalParams(isAdd,matrix,varargin)
%#codegen    
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.allowEnumInputs;
    coder.internal.prefer_const(varargin);


    popt=struct(...
    'CaseSensitivity',false,...
    'StructExpand',false,...
    'PartialMatching','unique',...
    'IgnoreNulls',false);

    if isAdd
        params=struct(...
        'alpha',uint32(0),...
        'beta',uint32(0),...
        'transpose',uint32(0));
    else
        params=struct(...
        'alpha',uint32(0),...
        'transpose',uint32(0));
    end

    pstruct=coder.internal.parseParameterInputs(params,popt,varargin{:});
    transposeStr=coder.internal.getParameterValue(pstruct.transpose,'NN',varargin{:});
    alpha=coder.internal.getParameterValue(pstruct.alpha,1.0,varargin{:});
    if isAdd
        beta=coder.internal.getParameterValue(pstruct.beta,1.0,varargin{:});
    else
        beta=0.0;
    end


    coder.internal.errorIf(~isscalar(alpha),'gpucoder:common:BatchedBlasAlphaBetaNonScalar','alpha');
    coder.internal.errorIf(~isscalar(beta),'gpucoder:common:BatchedBlasAlphaBetaNonScalar','beta');
    coder.internal.errorIf(~isnumeric(alpha),'gpucoder:common:BatchedBlasAlphaBetaNonNumeric','alpha',class(alpha));
    coder.internal.errorIf(~isnumeric(beta),'gpucoder:common:BatchedBlasAlphaBetaNonNumeric','beta',class(beta));
    coder.internal.errorIf(~isstring(transposeStr)&&~ischar(transposeStr),'gpucoder:common:BatchedBlasInvalidTransStrType');
    coder.internal.errorIf(~coder.internal.isConst(transposeStr),'gpucoder:common:BatchedBlasTransposeStrMustBeConst');
    coder.internal.errorIf(strlength(transposeStr)~=2,'gpucoder:common:BatchedBlasInvalidTransStrLen',strlength(transposeStr));

    transposeStr=upper(char(transposeStr));
    transA=transposeStr(1);
    transB=transposeStr(2);


    alpha=cast(alpha,'like',matrix);
    beta=cast(beta,'like',matrix);

end