function dataDicts = getAllDataDictionaries( model )












assert( isstring( model ) || ischar( model ) || ishandle( model ) );

modelName = model;
if ishandle( model )
modelName = get_param( model, 'Name' );
end 

if ~bdIsLoaded( modelName )
load_system( model );
end 

dataDicts = getAllDictionariesOfLibrary( model );

mdlUsedDD = get_param( model, 'DataDictionary' );
if ~isempty( mdlUsedDD )
if ~ismember( mdlUsedDD, dataDicts )
dataDicts{ end  + 1 } = mdlUsedDD;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpo1spvI.p.
% Please follow local copyright laws when handling this file.

