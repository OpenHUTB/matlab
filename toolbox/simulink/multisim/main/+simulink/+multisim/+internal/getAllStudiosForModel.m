function studios = getAllStudiosForModel( modelName, allStudios )


R36
modelName( 1, 1 )string
allStudios DAS.Studio = DAS.Studio.getAllStudiosSortedByMostRecentlyActive(  )
end 

studios = DAS.Studio.empty;
if bdIsLoaded( modelName ) && ~isempty( allStudios )
modelHandle = get_param( modelName, 'Handle' );

allApps = [ allStudios.App ];
appBlockDiagramHandles = [ allApps.blockDiagramHandle ];
studios = allStudios( appBlockDiagramHandles == modelHandle );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpqWatiz.p.
% Please follow local copyright laws when handling this file.

