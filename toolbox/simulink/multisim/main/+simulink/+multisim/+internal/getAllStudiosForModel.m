function studios = getAllStudiosForModel( modelName, allStudios )

arguments
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

