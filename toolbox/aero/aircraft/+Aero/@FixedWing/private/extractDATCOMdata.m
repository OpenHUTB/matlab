function datcomData = extractDATCOMdata( datcomStruct, field, states )




R36
datcomStruct
field( 1, 1 )string
states( :, 1 )string
end 

datcomData = datcomStruct.( field );






inds = repmat( { ':' }, size( states ) );
buildidx = states == "build";
if any( buildidx )
inds{ buildidx } = datcomStruct.build;
end 
datcomData = datcomData( inds{ : } );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp0Qzz1e.p.
% Please follow local copyright laws when handling this file.

