function status=executeBlockReplacements(obj)



    status=true;

    if obj.mSkipTranslation
        blockRepObj=Sldv.xform.BlkReplacer.getInstance(true);
        blockRepObj.StandAloneMode=false;
        originalModelH=obj.mExtractedModelH;
        replacementModelH=obj.mModelToCheckCompatH;
        if originalModelH~=replacementModelH
            Sldv.xform.BlkReplacer.createDDForReplacementMdl(originalModelH,replacementModelH,obj.mTestComp);
        end
        return;
    end

    if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus




        compatStatus=sldvprivate('mdl_check_inport_ofc',...
        obj.mExtractedModelH,obj.mCompatStatus.char);
        obj.mCompatStatus=Sldv.CompatStatus(compatStatus);
    end

    if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus



        if(slfeature('ObserverSLDV')==0)
            compatStatus=sldvprivate('mdl_check_observer_reference',...
            obj.mExtractedModelH,obj.mCompatStatus.char);
            obj.mCompatStatus=Sldv.CompatStatus(compatStatus);
        end
    end

    if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus



        compatStatus=sldvprivate('mdl_check_SLGlobalFcn_in_MdlRef',...
        obj.mExtractedModelH,obj.mCompatStatus.char);
        obj.mCompatStatus=Sldv.CompatStatus(compatStatus);
    end

    if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE~=obj.mCompatStatus

        obj.ignoreObserversWithinModelRefs();

        as=obj.mTestComp.activeSettings;
        blockRepObj=Sldv.xform.BlkReplacer.getInstance(true);
        blockRepObj.StandAloneMode=false;

        try
            [status,obj.mModelToCheckCompatH,~]=...
            blockRepObj.executeReplacements(obj.mExtractedModelH,as,obj.mShowUI,obj.mTestComp);
        catch MEx
            status=false;
            obj.mModelToCheckCompatH=obj.mExtractedModelH;
            sldvshareprivate('avtcgirunsupcollect','push',obj.mModelToCheckCompatH,...
            'simulink',...
            MEx.message,'SLDV:Compatibility:Generic');
        end
    else
        obj.mModelToCheckCompatH=obj.mExtractedModelH;
    end

    if~status
        obj.logNewLines(getString(message('Sldv:Setup:CheckingCompatibilityFailed')));
        if obj.mShowUI
            obj.logNewLines(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
        end
        obj.errorHalt(true);

        obj.clearDiagnosticInterceptor();
        obj.mErrorMsg=sldvshareprivate('avtcgirunsupdialog',obj.mExtractedModelH,obj.mShowUI);
        return;
    end

    obj.mModelToCheckCompatName=get_param(obj.mModelToCheckCompatH,'Name');
    obj.mModelToReportCompatibilityName=Sldv.Translator.modelToLogCompatibility(obj.mModelToCheckCompatName,obj.mTestComp);

    if~isempty(obj.mTestComp.analysisInfo.replacementInfo.replacementModelH)
        obj.mTestComp.analysisInfo.analyzedModelH=...
        obj.mTestComp.analysisInfo.replacementInfo.replacementModelH;
    end

end


