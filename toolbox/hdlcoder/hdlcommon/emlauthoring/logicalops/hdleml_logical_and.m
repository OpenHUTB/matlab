%#codegen
function y=hdleml_logical_and(varargin)


    coder.allowpcode('plain')

    t=varargin{1}&&varargin{2};
    for ii=3:nargin
        t=varargin{ii}&&t;
    end
    y=t;
