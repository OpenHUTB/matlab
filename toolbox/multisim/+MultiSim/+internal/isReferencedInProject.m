



function status=isReferencedInProject(refProjectRoot,proj)
    visitedProjects=containers.Map;
    status=locIsReferencedInProject(refProjectRoot,proj,visitedProjects);
end

function status=locIsReferencedInProject(refProjectRoot,proj,visitedProjects)
    status=false;
    refs=proj.ProjectReferences;
    for i=1:numel(refs)
        try
            projectRoot=refs(i).Project.RootFolder;
            if~isKey(visitedProjects,projectRoot)
                visitedProjects(projectRoot)=true;
                if strcmp(refProjectRoot,projectRoot)||locIsReferencedInProject(refProjectRoot,refs(i).Project,visitedProjects)
                    status=true;
                    break;
                end
            end
        catch ME




            if~strcmp(ME.identifier,'MATLAB:project:api:StaleProjectHandle')
                rethrow(ME);
            end
        end
    end
end