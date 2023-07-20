%#codegen
function y=hdleml_bitconcat(varargin)


    coder.allowpcode('plain')

    y=bitconcat(varargin{:});


