%#codegen
function y=hdleml_logical_nand(varargin)


    coder.allowpcode('plain')

    y=~hdleml_logical_and(varargin{:});
