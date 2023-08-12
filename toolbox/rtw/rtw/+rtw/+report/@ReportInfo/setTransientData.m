function setTransientData( obj, buildInfo )




startDir = buildInfo.Settings.LocalAnchorDir;

obj.BuildDirectory = fullfile( startDir, buildInfo.ComponentBuildFolder );
obj.StartDir = startDir;
obj.ModelName = buildInfo.ModelName;
obj.initGenUtilsPathBasedOnBuildDir(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnx3fhM.p.
% Please follow local copyright laws when handling this file.

