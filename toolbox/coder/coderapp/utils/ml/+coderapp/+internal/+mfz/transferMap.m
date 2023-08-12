function varargout = transferMap( srcMap, destMap )


R36
srcMap mf.zero.Map
destMap mf.zero.Map
end 

if ~srcMap.Type.isA( destMap.Type ) || ~srcMap.KeyType.isA( destMap.KeyType )
error( 'MF0 maps must have compatible key and value types to support transferring' );
end 

entries = srcMap.toArray(  );
for i = 1:numel( entries )
destMap.add( entries{ i } );
end 

if nargout ~= 0
varargout{ 1 } = destMap;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpiLwh8d.p.
% Please follow local copyright laws when handling this file.

