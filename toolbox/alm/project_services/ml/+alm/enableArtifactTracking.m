function prevState = enableArtifactTracking( prjFolder, newState )

arguments
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



