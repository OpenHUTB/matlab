function result = hasShadowedProjectFiles( project )

arguments
    project( 1, 1 ) = currentProject(  )
end

provider = matlab.internal.project.unsavedchanges.providers.SimulinkProvider;
files = provider.getLoadedFiles(  );

shadowedFiles = matlab.internal.project.unsavedchanges.filter.shadowedProjectFiles( files, project );
result = ~isempty( shadowedFiles );
end

