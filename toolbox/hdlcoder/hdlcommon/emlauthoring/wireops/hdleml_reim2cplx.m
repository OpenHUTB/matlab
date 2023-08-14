%#codegen
function y=hdleml_reim2cplx(mode,RealValue,ImagValue,varargin)


    coder.allowpcode('plain')

    eml_prefer_const(mode,RealValue,ImagValue);

    switch mode
    case 1

        y=complex(varargin{1},varargin{2});
    case 2

        y=complex(varargin{1},ImagValue);
    case 3

        y=complex(RealValue,varargin{1});
    end
