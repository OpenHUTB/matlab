function project=openProject(projectPath)












    narginchk(1,1);
    nargoutchk(0,1);

    validateattributes(projectPath,{'char','string'},{'nonempty'},'','projectPath');


    project=matlab.project.loadProject(projectPath);

end
