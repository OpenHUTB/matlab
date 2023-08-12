function data = getObjectData( objectId )





R36
objectId( 1, : )char
end 

object = evolutions.internal.getDataObject( objectId );
data = evolutions.internal.classhandler.ClassHandler.ReadObject( object );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGgsdKq.p.
% Please follow local copyright laws when handling this file.

