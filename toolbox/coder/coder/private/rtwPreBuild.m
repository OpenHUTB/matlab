function rtwPreBuild(project,configInfo,buildInfo,tflControl,lMexCompilerKey)




    bldDir=project.BldDirectory;


    mexCompInfo=coder.make.internal.getMexCompInfoFromKey(lMexCompilerKey);
    cleanupFcn=coder.internal.CompInfoCacheForCRL...
    .setMexCompInfoCache(mexCompInfo);

    if~isempty(tflControl)
        tflControl.runFcnImpCallbacks(bldDir);
        emcAddTflUsageInfoToBuildInfo(buildInfo,tflControl,bldDir);
    end

    if isprop(configInfo,'Hardware')&&~isempty(configInfo.Hardware)
        configInfo.Hardware.postCodegen(configInfo,buildInfo);
    end

    delete(cleanupFcn);
end
