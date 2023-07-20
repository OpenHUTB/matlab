function[res,mrefInfo]=getExcludedModels(excludedListStr)




    res=false;
    mrefInfo=[];
    if isempty(excludedListStr)
        return
    end

    mrefInfo=SlCov.Utils.extractExcludedModelInfo(excludedListStr);
    if~isempty(mrefInfo.normal)||~isempty(mrefInfo.accel)
        res=[mrefInfo.normal,mrefInfo.accel];
    end
