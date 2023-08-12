classdef constantLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer


properties 
Value
end 

methods 
function layer = constantLayer( NameValueArgs )


R36
NameValueArgs.Name = 'constant';
NameValueArgs.Value = 0;
end 

name = NameValueArgs.Name;
layer.Value = NameValueArgs.Value;


layer.Name = name;


layer.Description = "constant layer";


layer.Type = "ConstantLayer";

end 

function Z = predict( ~, X )
Z = cast( zeros( size( X ) ), 'like', X );
Z = dlarray( Z );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7rZyKu.p.
% Please follow local copyright laws when handling this file.

