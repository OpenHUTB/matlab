function setToolEmpty( obj )


if obj.hAvailableToolList.isToolListEmpty
obj.set( 'Tool', obj.NoAvailableToolStr );
else 
obj.set( 'Tool', obj.EmptyToolStr );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJpdxXC.p.
% Please follow local copyright laws when handling this file.

