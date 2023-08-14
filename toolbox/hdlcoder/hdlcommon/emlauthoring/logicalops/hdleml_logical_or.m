%#codegen
function y=hdleml_logical_or(varargin)


    coder.allowpcode('plain')

    t=varargin{1}||varargin{2};
    for ii=3:nargin
        t=varargin{ii}||t;
    end
    y=t;
