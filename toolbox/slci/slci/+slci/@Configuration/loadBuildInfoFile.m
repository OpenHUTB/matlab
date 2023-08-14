




function buildInfo=loadBuildInfoFile(aObj)
    build_info_full_path=...
    [aObj.getDerivedCodeFolder(),filesep,'buildInfo.mat'];
    if~exist(build_info_full_path,'file')
        DAStudio.error('Slci:report:MissingBuildInfo');
    end



    if~aObj.getVerbose()
        msgID='MATLAB:load:classNotFound';
        warnObj=warning('off',msgID);
    end
    buildInfo=load(build_info_full_path);

    if~strcmpi(aObj.getCodePlacement(),'Single folder')

        buildInfo.buildInfo.postLoadUpdate(aObj.getDerivedCodeFolder());
    end

    if~aObj.getVerbose()
        warning(warnObj.state,warnObj.identifier);
    end

end
