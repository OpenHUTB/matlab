%#codegen
function y=hdleml_bitxor(varargin)


    coder.allowpcode('plain')

    t=eml_bitxor(varargin{1},varargin{2});
    for ii=3:nargin
        t=eml_bitxor(varargin{ii},t);
    end
    y=t;
