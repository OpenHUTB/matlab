%#codegen


function z=dts_ones(varargin)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('always');
    z=dts_cast(ones(varargin{:}));
end
