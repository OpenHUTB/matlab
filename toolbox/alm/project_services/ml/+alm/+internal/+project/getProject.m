


function proj=getProject(rootFolder)
    loadedProjects=slproject.getCurrentProjects;
    idx=strcmp(rootFolder,{loadedProjects.RootFolder});

    if any(idx)
        proj=loadedProjects(idx);
    else
        error(message('alm:project_except:ProjectNotLoaded',rootFolder));
    end
end
