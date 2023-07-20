function path=getToolPath(obj)

    binPath=obj.hToolDriver.hTool.ToolPath;
    path=fileparts(binPath);
    path=strrep(path,'\','/');
end
