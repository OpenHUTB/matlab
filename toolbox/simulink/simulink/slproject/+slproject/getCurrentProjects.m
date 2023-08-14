function projects=getCurrentProjects()






    project=matlab.project.rootProject();
    if isempty(project)
        projects=slproject.ProjectManager.empty(1,0);
    else
        projects=slproject.ProjectManager(project);
    end
end
