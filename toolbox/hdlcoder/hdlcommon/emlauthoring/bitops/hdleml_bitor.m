%#codegen
function y=hdleml_bitor(varargin)


    coder.allowpcode('plain')

    t=eml_bitor(varargin{1},varargin{2});
    for ii=3:nargin
        t=eml_bitor(varargin{ii},t);
    end
    y=t;
