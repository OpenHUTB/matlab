classdef padLayer < nnet.layer.Layer & nnet.layer.Formattable & dnnfpga.layer.NotCustomLayer

properties ( Access = private )
added
first = true
end 
properties 
OutputSize
end 

methods 
function layer = padLayer( outputSize, NameValueArgs )

R36
outputSize{ mustBeNumeric, mustBeNonempty,  ...
mustBeReal, mustBeFinite, mustBeInteger, mustBePositive }
NameValueArgs.Name = '';
end 

name = NameValueArgs.Name;


layer.Name = name;


layer.Description = "pad layer";


layer.Type = "Pad Layer";

if isscalar( outputSize )
outputSize = [ outputSize, 1, 1 ];
end 

layer.OutputSize = outputSize;
end 

function Z = predict( layer, X )
if layer.first
inSize = numel( X );
outSize = prod( layer.OutputSize );
delta = uint32( outSize - inSize );
added = zeros( 1, delta, 'like', X );
layer.added = added;
layer.first = false;
if delta < uint32( 0 )
msg = "In padLayer '%s', the output size must be greater than or equal to the input size.";
error( msg, layer.Name );
end 
end 
Z = horzcat( reshape( X, 1, [  ] ), added );
Z = reshape( Z, layer.OutputSize );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp752kpN.p.
% Please follow local copyright laws when handling this file.

