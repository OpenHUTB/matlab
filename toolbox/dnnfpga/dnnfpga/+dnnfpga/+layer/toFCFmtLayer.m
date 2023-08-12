classdef toFCFmtLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer

methods 
function layer = toFCFmtLayer( NameValueArgs )

R36
NameValueArgs.Name = 'toFC';
end 

name = NameValueArgs.Name;


layer.Name = name;


layer.Description = "toFCFmt layer";


layer.Type = "toFCFmtLayer";

end 

function Z = predict( ~, X )


Z = X;

end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfb4dKo.p.
% Please follow local copyright laws when handling this file.

