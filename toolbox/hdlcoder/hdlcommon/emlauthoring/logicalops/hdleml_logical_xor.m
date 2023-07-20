%#codegen
function y=hdleml_logical_xor(varargin)


    coder.allowpcode('plain')

    t=xor(varargin{1},varargin{2});
    for ii=3:nargin
        t=xor(varargin{ii},t);
    end
    y=t;
