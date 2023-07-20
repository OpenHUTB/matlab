function TF=isProjectLoaded(projectRoot)



    loadedProjects=slproject.getCurrentProjects();
    if isempty(loadedProjects)
        TF=false;
    else
        loadedProjectRoots={loadedProjects.RootFolder};
        TF=any(strcmp(loadedProjectRoots,projectRoot));
    end

end