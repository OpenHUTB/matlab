function data = getObjectData( objectId )


R36
objectId( 1, : )char
end 

object = evolutions.internal.getDataObject( objectId );
data = evolutions.internal.classhandler.ClassHandler.ReadObject( object );
end 



