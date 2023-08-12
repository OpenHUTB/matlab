classdef identityLayer < nnet.layer.Layer & nnet.layer.Formattable


methods 
function layer = identityLayer( NameValueArgs )


R36
NameValueArgs.Name = 'identity';
end 

name = NameValueArgs.Name;


layer.Name = name;


layer.Description = "identity layer";


layer.Type = "IdentityLayer";

end 

function Z = predict( layer, X )


Z = X;

end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpiwPKww.p.
% Please follow local copyright laws when handling this file.

