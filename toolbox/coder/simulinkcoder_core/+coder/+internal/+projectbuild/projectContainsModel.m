function[modelInProject,file]=projectContainsModel(project,model)





    validateattributes(project,{'slproject.ProjectManager'},{'size',[1,1]});

    modelFilename=Simulink.MDLInfo(model).FileName;
    file=project.findFile(modelFilename);
    modelInProject=~isempty(file);
end

