classdef labelLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer


methods 
function layer = labelLayer( NameValueArgs )



R36
NameValueArgs.Name = 'label';
end 

name = NameValueArgs.Name;


layer.Name = name;


layer.Description = "label layer";


layer.Type = "LabelLayer";

end 

function Z = predict( layer, X )


Z = X;

end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpVfQq5r.p.
% Please follow local copyright laws when handling this file.

