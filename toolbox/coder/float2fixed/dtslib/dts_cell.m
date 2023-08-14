%#codegen


function c=dts_cell(varargin)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    coder.inline('always');
    coder.internal.prefer_const(varargin);

    coder.internal.assert(false,'Coder:FXPCONV:DTS_SingleC_CellArraysNotSupported');
    c=cell(varargin{:});
end


