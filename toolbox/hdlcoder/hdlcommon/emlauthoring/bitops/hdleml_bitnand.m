%#codegen
function y=hdleml_bitnand(varargin)


    coder.allowpcode('plain')



    t=eml_bitand(varargin{1},varargin{2});
    for ii=3:nargin
        t=eml_bitand(varargin{ii},t);
    end
    y=eml_bitnot(t);







