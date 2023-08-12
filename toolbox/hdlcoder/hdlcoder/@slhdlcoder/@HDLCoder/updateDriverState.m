function updateDriverState( this, fullpath, nname )




p = pir( this.AllModels( this.mdlIdx ).modelName );
existingNames = p.getEntityNames;
loc = strcmpi( nname, existingNames );
if any( loc )
error( message( 'hdlcoder:engine:invalidarg', nname ) )
end 

p.addEntityNameAndPath( nname, fullpath );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpduilEo.p.
% Please follow local copyright laws when handling this file.

