





function mustBeValidModel( model, msgId )
R36
model
msgId = 'SimBiology:validation:InvalidModel'
end 
if ~( isa( model, "SimBiology.Model" ) && isscalar( model ) && isvalid( model ) )
error( message( msgId ) )
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpImAYly.p.
% Please follow local copyright laws when handling this file.

