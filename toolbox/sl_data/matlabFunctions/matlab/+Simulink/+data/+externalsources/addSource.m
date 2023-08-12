function addSource( modelName, externalSource )



R36
modelName( 1, 1 )string
externalSource( 1, 1 )string
end 

if ~bdIsLoaded( modelName )
error( message( 'sl_data_adapter:messages:ModelUnloaded' ) );
end 
if bdIsLibrary( modelName )
error( message( 'sl_data_adapter:messages:CannotUpdateLibraryAdd' ) );
end 
if ~isfile( externalSource )
error( message( 'sl_data_adapter:messages:ExternalSourceNotFound', externalSource ) );
end 

[ ~, filename, ext ] = fileparts( externalSource );

fname = strcat( filename, ext );
if strcmpi( ext, '.sldd' )
currentDDName = get_param( modelName, 'DataDictionary' );
if ~isempty( currentDDName )
error( message( 'sl_data_adapter:messages:OnlyOneDataDictionary' ) );
end 
set_param( modelName, 'DataDictionary', fname );
elseif strcmpi( ext, '.m' ) || strcmpi( ext, '.mat' )
currentESList = get_param( modelName, 'ExternalSources' );
if isequal( currentESList, { [  ] } )
currentESList = { fname };
else 
if contains( currentESList, fname )
error( message( 'sl_data_adapter:messages:AlreadyAttached', fname ) );
end 
currentESList{ end  + 1 } = fname;
end 
set_param( modelName, 'ExternalSources', currentESList );
else 
error( message( 'sl_data_adapter:messages:InvalidSource' ) );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpt1wsOv.p.
% Please follow local copyright laws when handling this file.

