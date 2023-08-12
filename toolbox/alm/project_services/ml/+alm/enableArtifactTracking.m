function prevState = enableArtifactTracking( prjFolder, newState )




R36
prjFolder{ mustBeFolder }
newState{ islogical }
end 


if alm.internal.project.isJsEnabled(  )
ps = alm.internal.ProjectService.get( prjFolder );
pa = ps.getAdapter(  );
prevState = pa.enableArtifactTracking( newState );
else 
prevState = alm.isArtifactTrackingEnabled( prjFolder );
com.mathworks.toolbox.alm.project_services.ProjectServicesEnvironmentCustomization.setEnabled( prjFolder, newState );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0uOQjL.p.
% Please follow local copyright laws when handling this file.

