function pm = get( topLevelProject )




R36
topLevelProject = currentProject
end 

persistent localObj
if isempty( localObj ) || ~isvalid( localObj )
localObj = evolutions.internal.project.ProjectManager( topLevelProject );
localObj.initialize;
end 
pm = localObj;


pm.TopLevelProject = topLevelProject;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUwj5SG.p.
% Please follow local copyright laws when handling this file.

