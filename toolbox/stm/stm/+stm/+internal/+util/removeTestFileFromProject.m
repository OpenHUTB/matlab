function removeTestFileFromProject(tfObj)





    id=tfObj.id;

    filePath=stm.internal.getTestProperty(id,'testsuite').location;

    fileToProjectMapper=Simulink.ModelManagement.Project.Util.FileToProjectMapper(...
    @()i_extractFile(filePath)...
    );
    project=fileToProjectMapper.findLoadedProjectWithRoot();
    project.removeFile(fileToProjectMapper.File);
end

function out=i_extractFile(filePath)
    out=filePath;
end