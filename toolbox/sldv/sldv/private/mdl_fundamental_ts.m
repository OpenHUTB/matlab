function ts=mdl_fundamental_ts(modelH,testcomp)



    if~isempty(testcomp),
        ts=testcomp.mdlFundamentalTs;
    else
        dirtyBef=get_param(modelH,'Dirty');
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
        set_param(modelH,'RTWExternMdlXlate',1);
        covEnb=get_param(modelH,'RecordCoverage');
        set_param(modelH,'RecordCoverage','on');
        sldvshareprivate('avtcgirunsupcollect','disablePushMethod');
        try
            mdlObj=get_param(modelH,'Object');
            mdlSampleTimes=mdlObj.getSampleTimeValues();
        catch Mex %#ok<NASGU>
        end
        sldvshareprivate('avtcgirunsupcollect','enablePushMethod');
        set_param(modelH,'RTWExternMdlXlate',0);
        set_param(modelH,'RecordCoverage',covEnb);
        set_param(modelH,'Dirty',dirtyBef);
        ts=sldvshareprivate('mdl_derive_sampletime_for_sldvdata',mdlSampleTimes);
    end
