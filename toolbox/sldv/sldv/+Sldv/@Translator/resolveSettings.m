function status=resolveSettings(obj)




    try
        status=sldvprivate('resolve_settings',...
        obj.mExtractedModelH,obj.mTestComp,false,obj.mShowUI,obj.mSkipTranslation);
        Mex=[];
    catch Mex
        status=false;
    end

    if~status
        if~isempty(Mex)
            base_ME=MException('Sldv:Setup:settings',...
            getString(message('Sldv:Setup:FailedToSetupResultsDirectories')));
            new_ME=addCause(base_ME,Mex);
            throw(new_ME);
        end
    end

    if obj.mSkipTranslation&&...
        strcmp(obj.mTestComp.activeSettings.BlockReplacement,'on')&&...
        isfield(obj.mTestComp.analysisInfo,'replacementInfo')
        obj.mTestComp.resolvedSettings.BlockReplacementModelFileName=get_param(obj.mTestComp.analysisInfo.replacementInfo.replacementModelH,'filename');
        obj.mTestComp.resolvedSettings.modelHBeforeBlockReplacements=obj.mExtractedModelH;
    end
end
