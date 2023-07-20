function menuStatus=getProjectMenuStatus(tfObj)



    menuStatus.InAProject=false;
    menuStatus.InALoadedProject=false;
    menuStatus.InRootOfALoadedProject=false;

    try
        id=tfObj.id;

        filePath=stm.internal.getTestProperty(id,'testsuite').location;

        fileToProjectMapper=Simulink.ModelManagement.Project.Util.FileToProjectMapper(...
        @()i_extractFile(filePath)...
        );

        menuStatus.InAProject=fileToProjectMapper.InAProject;
        menuStatus.InALoadedProject=fileToProjectMapper.InALoadedProject;
        menuStatus.InRootOfALoadedProject=fileToProjectMapper.InRootOfALoadedProject;
    catch me %#ok
    end

end

function out=i_extractFile(filePath)
    out=filePath;
end

