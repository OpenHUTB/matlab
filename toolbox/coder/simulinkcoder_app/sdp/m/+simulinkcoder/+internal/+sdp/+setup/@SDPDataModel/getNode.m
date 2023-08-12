function node = getNode( obj, id )



R36
obj
id
end 

if obj.nodeMap.isKey( id )
node = obj.nodeMap( id );
else 
node = simulinkcoder.internal.sdp.setup.SDPModelNode( id );
obj.nodeMap( id ) = node;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpn7dLlw.p.
% Please follow local copyright laws when handling this file.

