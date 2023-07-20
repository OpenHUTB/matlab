%#codegen


function z=dts_zeros(varargin)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('always');
    z=dts_cast(zeros(varargin{:}));
end
