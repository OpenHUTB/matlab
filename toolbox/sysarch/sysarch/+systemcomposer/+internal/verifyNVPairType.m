function verifyNVPairType( arg, name, expectedTypes )

if ~iscell( expectedTypes )
expectedTypes = { expectedTypes };
end 

for i = 1:numel( expectedTypes )
if ( isa( arg, expectedTypes{ i } ) )
return 
end 
end 

systemcomposer.internal.throwAPIError( 'InvalidValForNVPair', name,  ...
strjoin( expectedTypes, ' or ' ) );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpTEsnl4.p.
% Please follow local copyright laws when handling this file.

