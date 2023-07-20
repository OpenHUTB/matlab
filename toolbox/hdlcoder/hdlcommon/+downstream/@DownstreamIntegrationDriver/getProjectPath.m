function value=getProjectPath(obj)


    if obj.isIPCoreGen
        value=obj.hIP.getEmbeddedToolProjFolder;
    else
        value=obj.hToolDriver.getProjectPath;
    end

end
