function removeSource( modelName, externalSource )

arguments
    modelName( 1, 1 )string
    externalSource( 1, 1 )string
end

if ~bdIsLoaded( modelName )
    error( message( 'sl_data_adapter:messages:ModelUnloaded' ) );
end
if bdIsLibrary( modelName )
    error( message( 'sl_data_adapter:messages:CannotUpdateLibraryRemove' ) );
end

[ ~, filename, ext ] = fileparts( externalSource );

fname = strcat( filename, ext );
if strcmpi( ext, '.sldd' )
    currentDDName = get_param( modelName, 'DataDictionary' );
    if ~strcmpi( currentDDName, fname )
        error( message( 'sl_data_adapter:messages:DataDictionaryNotAttached', externalSource ) );
    end
    set_param( modelName, 'DataDictionary', '' );

    currentESList = get_param( modelName, 'ExternalSources' );
    if ~isempty( currentESList{ 1 } ) && any( contains( currentESList, fname ) )
        removeFromExternalSources( modelName, currentESList, fname );
    end
elseif strcmpi( ext, '.m' ) || strcmpi( ext, '.mat' )
    currentESList = get_param( modelName, 'ExternalSources' );
    if isempty( currentESList{ 1 } ) || ~any( contains( currentESList, fname ) )
        error( message( 'sl_data_adapter:messages:ExternalSourceNotAttached', fname ) );
    end
    removeFromExternalSources( modelName, currentESList, fname );
else
    error( message( 'sl_data_adapter:messages:InvalidSource' ) );
end
end

function removeFromExternalSources( modelName, currentList, fileToBeRemoved )
for i = 1:numel( currentList )
    if strcmp( currentList{ i }, fileToBeRemoved )
        break ;
    end
end
currentList( i ) = [  ];
set_param( modelName, 'ExternalSources', currentList );
end


