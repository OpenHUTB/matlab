function path=getBitstreamPath(obj,targetDir)



    if nargin<2
        targetDir='';
    end


    if obj.isIPCoreGen
        path=obj.hIP.getBitstreamPath;
    else
        path=obj.hToolDriver.getBitstreamPath;
    end


    if~isempty(targetDir)
        path=strrep(path,[targetDir,filesep],'');
    end

end