


function status=isLoaded(rootFolder)
    loadedProjects=slproject.getCurrentProjects;
    status=any(strcmp(rootFolder,{loadedProjects.RootFolder}));
end
