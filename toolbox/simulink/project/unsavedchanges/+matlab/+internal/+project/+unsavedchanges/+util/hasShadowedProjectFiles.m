function result = hasShadowedProjectFiles( project )




R36
project( 1, 1 ) = currentProject(  )
end 

provider = matlab.internal.project.unsavedchanges.providers.SimulinkProvider;
files = provider.getLoadedFiles(  );

shadowedFiles = matlab.internal.project.unsavedchanges.filter.shadowedProjectFiles( files, project );
result = ~isempty( shadowedFiles );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpq5t35J.p.
% Please follow local copyright laws when handling this file.

