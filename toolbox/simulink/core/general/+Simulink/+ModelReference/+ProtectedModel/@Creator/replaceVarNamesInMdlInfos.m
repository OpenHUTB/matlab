function replaceVarNamesInMdlInfos(obj)







    if isempty(obj.UnprotectedParamIdToProtectedId)||~obj.supportsCodeGen()
        return;
    end


    if strcmp(obj.CodeInterface,'Model reference')
        mdlRefTgtType='RTW';
    else
        mdlRefTgtType='NONE';
    end


    lSystemTargetFile=get_param(obj.ModelName,'SystemTargetFile');
    infoStruct=coder.internal.infoMATPostBuild...
    ('load','binfo',obj.ModelName,mdlRefTgtType,lSystemTargetFile);
    mdlInfos=infoStruct.mdlInfos;
    if~isempty(mdlInfos)
        for i=1:length(mdlInfos.mdlInfo)
            currentInfo=mdlInfos.mdlInfo{i};
            if isKey(obj.UnprotectedParamIdToProtectedId,currentInfo.Id)
                mdlInfos.mdlInfo{i}.Id=obj.UnprotectedParamIdToProtectedId(currentInfo.Id);
            end
        end


        infoStruct=coder.internal.infoMATPostBuild...
        ('updateField','binfo',obj.ModelName,mdlRefTgtType,...
        lSystemTargetFile,...
        'mdlInfos',mdlInfos);
        fullMatFileName=coder.internal.infoMATPostBuild...
        ('getMatFileName','binfo',obj.ModelName,mdlRefTgtType,...
        lSystemTargetFile);
        coder.internal.saveMinfoOrBinfo(infoStruct,fullMatFileName);

    end
end
