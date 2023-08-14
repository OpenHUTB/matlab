function build(projectManager,model)






    validateattributes(projectManager,{'slproject.ProjectManager'},{'size',[1,1]});

    if~ischar(model)

        if~ishandle(model)
            DAStudio.error('Simulink:utility:incorrectSLBuildUsage');
        end


        model=get_param(model,'Name');
    end


    if coder.internal.projectbuild.projectContainsModel(projectManager,model)

        builder=coder.internal.projectbuild.ProjectModelBuilder(projectManager,model);
        builder.build();
    else
        DAStudio.error('RTW:buildProcess:projectBuildNoContainModel',projectManager.Name,model);
    end
end


