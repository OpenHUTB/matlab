function openProject(tfObj)



    id=tfObj.id;

    filePath=stm.internal.getTestProperty(id,'testsuite').location;

    fileToProjectMapper=Simulink.ModelManagement.Project.Util.FileToProjectMapper(...
    @()i_extractFile(filePath)...
    );

    if~fileToProjectMapper.InAProject
        error(message('SimulinkProject:menu:ModelNotInProject'));
    end
    slproject.loadProject(fileToProjectMapper.ProjectRoot);
end

function out=i_extractFile(filePath)
    out=filePath;
end
