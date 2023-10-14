function pm = get( topLevelProject )

arguments
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

