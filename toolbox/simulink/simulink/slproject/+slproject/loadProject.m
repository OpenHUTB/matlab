function project=loadProject(projectLocation)












    validateattributes(projectLocation,{'char','string'},{'nonempty'},'','projectLocation');

    mProject=matlab.project.loadProject(projectLocation);
    project=slproject.ProjectManager(mProject);
end
