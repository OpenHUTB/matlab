function[dimArg,preproArg,pstruct]=parseReduceOptionalParams(varargin)
%#codegen



    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(varargin);

    popt=struct(...
    'CaseSensitivity',false,...
    'StructExpand',false,...
    'PartialMatching','unique',...
    'IgnoreNulls',false);

    params=struct(...
    'dim',uint32(0),...
    'preprocess',uint32(0));

    pstruct=coder.internal.parseParameterInputs(params,popt,varargin{:});
    preproArg=coder.internal.getParameterValue(pstruct.preprocess,[],varargin{:});
    dimArg=coder.internal.getParameterValue(pstruct.dim,[],varargin{:});
end
