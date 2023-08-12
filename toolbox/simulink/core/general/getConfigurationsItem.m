function symbolValue = getConfigurationsItem( symbolName, dataLocation, varargin )

















[ symbolValue, resolvedLocation ] = slprivate( 'getScopeSectionItem', symbolName,  ...
dataLocation, 'Configurations', varargin{ : } );

if resolvedLocation == "base"

if ~isa( symbolValue, 'Simulink.ConfigSetRoot' )
error( message( 'SLDD:sldd:EntryNotFound' ) );
end 
else 
configset.internal.util.setSourceLocation( symbolValue, dataLocation );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp_vJW_6.p.
% Please follow local copyright laws when handling this file.

