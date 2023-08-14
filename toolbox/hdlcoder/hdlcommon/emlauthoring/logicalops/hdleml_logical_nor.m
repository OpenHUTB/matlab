%#codegen
function y=hdleml_logical_nor(varargin)


    coder.allowpcode('plain')

    y=~hdleml_logical_or(varargin{:});
