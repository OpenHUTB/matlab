function compatStatus=observerCompileTimeCompatChecks(obj)





    compatStatus=obj.mCompatStatus.char;

    modelH=obj.mModelToCheckCompatH;

    if strcmp(get_param(modelH,'IsObserverBD'),'off')







        return;
    end

    compatStatus=checkForDifferentSampleTimes(modelH,compatStatus);
    if strcmp('DV_COMPAT_INCOMPATIBLE',compatStatus)
        return;
    end
end

function compatStatus=checkForDifferentSampleTimes(obsModelH,compatStatus)
    if strcmp('DV_COMPAT_INCOMPATIBLE',compatStatus)
        return;
    end

    obsMdlObj=get_param(obsModelH,'Object');
    obsMdlSampleTimes=obsMdlObj.getSampleTimeValues();
    obsMdlFundamentalTs=...
    sldvshareprivate('mdl_derive_sampletime_for_sldvdata',...
    obsMdlSampleTimes);

    obsRefH=Simulink.observer.internal.getObsRefBlkCtx(obsModelH);
    topModelH=bdroot(obsRefH);
    topMdlObj=get_param(topModelH,'Object');
    topMdlSampleTimes=topMdlObj.getSampleTimeValues();
    topMdlFundamentalTs=...
    sldvshareprivate('mdl_derive_sampletime_for_sldvdata',...
    topMdlSampleTimes);



    incompatCondition=~isequal(obsMdlFundamentalTs,topMdlFundamentalTs);

    if incompatCondition
        errMsgObs=getString(message('Sldv:Observer:IgnoreIncompatObs',getfullname(obsModelH)));
        sldvshareprivate('avtcgirunsupcollect','push',obsModelH,'sldv_warning',errMsgObs,...
        'Sldv:Observer:IgnoreIncompatObs');

        errMsg=getString(message('Sldv:Observer:UnsupObsDiffRates',...
        getfullname(topModelH),string(topMdlFundamentalTs),getfullname(obsModelH),string(obsMdlFundamentalTs)));
        sldvshareprivate('avtcgirunsupcollect','push',topModelH,'sldv_warning',errMsg,...
        'Sldv:Observer:UnsupObsDiffRates');

        compatStatus='DV_COMPAT_INCOMPATIBLE';
        return;
    end
end
