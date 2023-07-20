function[inSystem,system,type]=isModelInSystem(projectSystem,model)





    validateattributes(projectSystem,...
    {'slproject.ProjectManager';
    'coder.internal.projectbuild.ProjectData';...
    'coder.internal.projectbuild.System'},...
    {'size',[1,1]});

    if isa(projectSystem,'slproject.ProjectManager')
        projectData=coder.internal.projectbuild.ProjectData(projectSystem);
    elseif isa(projectSystem,'coder.internal.projectbuild.ProjectData')
        projectData=projectSystem;
    end

    if isa(projectSystem,'coder.internal.projectbuild.System')
        type=projectSystem.getModelType(model);
        system=projectSystem;
    else
        [type,system]=projectData.getModelType(model);
    end

    inSystem=type~=coder.internal.projectbuild.SystemModelType.None;
end


