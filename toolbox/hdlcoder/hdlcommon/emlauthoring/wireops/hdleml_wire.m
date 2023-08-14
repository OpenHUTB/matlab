%#codegen
function varargout=hdleml_wire(varargin)


    coder.allowpcode('plain')

    for ii=coder.unroll(1:nargin)
        varargout{ii}=varargin{ii};
    end

