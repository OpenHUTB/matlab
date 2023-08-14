function emcAddTflUsageInfoToBuildInfo(buildInfo,hRtwFcnLib,bldDir)









    if isempty(hRtwFcnLib)
        return;
    end
    if~isa(hRtwFcnLib,'RTW.TflControl')
        error(message('Coder:buildProcess:tflControlMissing'));
    end

    excludeHdrs={};
    isSharedLoc=false;
    isCompactFormat=false;
    [~,~,hdrPaths,~]=coder.internal.addCRLUsageInfoToBuildInfo(buildInfo,...
    hRtwFcnLib,...
    bldDir,...
    excludeHdrs,...
    isSharedLoc,...
    isCompactFormat);
    if(~isempty(hdrPaths))
        buildInfo.addIncludePaths(hdrPaths,'TFL');
    end


