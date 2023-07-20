function[tool,link]=getProjectToolLink(obj)




    if(obj.isIPCoreGen)
        tool=obj.hIP.getEmbeddedTool;
        link=obj.hIP.getEmbeddedToolProjectLink;
    else
        tool=sprintf('%s %s',obj.hToolDriver.getToolName,obj.hToolDriver.getToolVersion);
        link=obj.hToolDriver.hTool.getProjectLink;
    end