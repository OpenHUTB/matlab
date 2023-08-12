function file = exportProjectToVersion( project, zipfile, targetRelease, includeReferences )






R36
project( 1, 1 )matlab.project.Project;
zipfile( 1, 1 )string;
targetRelease( 1, 1 )string;
includeReferences( 1, 1 )logical = false;
end 

projectExporter =  ...
Simulink.ModelManagement.Project.exportProjectToPreviousVersion( project,  ...
convertCharsToStrings( zipfile ),  ...
convertCharsToStrings( targetRelease ),  ...
includeReferences );

projectExporter.export;
file = projectExporter.ExportedProject;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2VP8de.p.
% Please follow local copyright laws when handling this file.

