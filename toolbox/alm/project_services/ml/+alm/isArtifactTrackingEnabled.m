function state = isArtifactTrackingEnabled( prjFolder )




R36
prjFolder{ mustBeFolder }
end 

prj = matlab.project.currentProject(  );

if isempty( prj ) || ~strcmp( prj.RootFolder, prjFolder )
error( message( 'alm:project_except:ProjectNotLoaded', prjFolder ) );
end 

if alm.internal.project.isJsEnabled(  )
ps = alm.internal.ProjectService.get( prjFolder );
pa = ps.getAdapter(  );
state = pa.isArtifactTrackingEnabled(  );
else 
state = com.mathworks.toolbox.alm.project_services.ProjectServicesEnvironmentCustomization.isEnabled( prjFolder );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMu7k69.p.
% Please follow local copyright laws when handling this file.

