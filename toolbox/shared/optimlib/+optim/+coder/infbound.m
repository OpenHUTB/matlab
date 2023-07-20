function bnds=infbound(varargin)
























%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(varargin);

    if nargin>0

        coder.unroll();
        for k=1:nargin
            coder.internal.errorIf(coder.internal.isCharOrScalarString(varargin{k}),...
            'optimlib_codegen:infbound:NumericParamsOnly');
        end
    end


    bnds=coder.internal.inf(varargin{:});