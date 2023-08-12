function verifyAPIArgumentType( arg, argNum, expectedTypes )

if ~iscell( expectedTypes )
expectedTypes = { expectedTypes };
end 

for i = 1:numel( expectedTypes )
if ( isa( arg, expectedTypes{ i } ) )
return 
end 
end 

systemcomposer.internal.throwAPIError( 'InvalidArgType', argNum,  ...
strjoin( expectedTypes, ' or ' ) );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7z3CuS.p.
% Please follow local copyright laws when handling this file.

