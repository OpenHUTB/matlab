function value=getProjectFile(obj)


    if obj.isIPCoreGen
        value=obj.hIP.getToolProjectFileName;
    else
        value=obj.hToolDriver.getProjectFile;
    end

end

