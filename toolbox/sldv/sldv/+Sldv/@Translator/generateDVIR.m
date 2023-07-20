function[status,msg]=generateDVIR(obj,topModelH,translationInfo,isMdlRefTranslation,buildArgs)




    obj.mIsTranslatorForComponent=true;


    obj.mCacheDirFullPath=sldvprivate('getSldvCacheDIR',...
    topModelH,obj.mBlockH,obj.mTestComp.activeSettings.Mode,obj.mIsXIL);


    obj.mCacheFileName=get_param(obj.mRootModelH,'Name');




    obj.clearCache();










    sldvshareprivate('avtcgirunsupcollect','enableForcedWarning');
    cleanUpForcedWarning=onCleanup(@()sldvshareprivate('avtcgirunsupcollect','disableForcedWarning'));









    obj.mBlkHs=translationInfo.Blocks;
    obj.mBlkTypes=translationInfo.BlockTypes;
    obj.mStubsfcns=translationInfo.StubSFunctions;


    obj.mStartupBlkHs=obj.getStartupVariantBlkHs();


    obj.initializeSIDMaps();





    obj.mTestComp.verifSubsys=sldvprivate('getAllVerificationSubsystems',obj.mBlkHs,obj.mBlkTypes);


    status=obj.setInputCovDataAndFilter();
    if~status

        obj.setOutputOnAbnormalTermination();
        status=false;
        msg=obj.mErrorMsg;
        return;
    end


    obj.mSettingsCache=sldvprivate('settings_handler',...
    obj.mModelToCheckCompatH,'store',[],obj.mTestComp,obj.mStartupBlkHs);

    settingsCleanup=onCleanup(@()sldvprivate('settings_handler',...
    obj.mModelToCheckCompatH,'restore',...
    obj.mSettingsCache,obj.mTestComp));
    obj.mSettingsCache=sldvprivate('settings_handler',...
    obj.mModelToCheckCompatH,'init_coverage',obj.mSettingsCache,obj.mTestComp);
    if~obj.mSkipTranslation
        obj.logAll(getString(message('Sldv:Setup:CompilingModel')));
    end
    obj.initCoverage();
    if~(Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE==obj.mCompatStatus)&&obj.mFilterExistingCov
        status=obj.fullCoverageAcheived;
        if~status
            obj.setOutputOnAbnormalTermination();
            status=false;
            msg=obj.mErrorMsg;
            return;
        end
    end




    obj.logAll(sprintf('%s\n',getString(message('Sldv:Setup:Done'))));





    if Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE==obj.mCompatStatus
        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
    else







        if~obj.mSkipTranslation














            obj.mTestComp.forcedTurnOnRelationalBoundary=false;
            if strcmp(obj.mTestComp.activeSettings.ModelCoverageObjectives,'EnhancedMCDC')
                obj.mTestComp.activeSettings.ModelCoverageObjectives='MCDC';
                activeSettingsCleanUp=onCleanup(@()restoreActiveSettings(obj,...
                'ModelCoverageObjectives','EnhancedMCDC'));
            end
        end


        if~obj.mSkipTranslation

            obj.translateAndCheckCompat(isMdlRefTranslation,buildArgs);
        end
    end

    if obj.mCompatStatus==Sldv.CompatStatus.DV_COMPAT_UNKNOWN
        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_COMPATIBLE;
        obj.mTestComp.compatStatus=obj.mCompatStatus.char;
    end


    obj.mSuccessStatus=getCompatStatus(obj);


    try
        tStatus=obj.saveCompatData();
    catch
        tStatus=false;
    end
    if~tStatus
        obj.clearCache();
    end


    status=obj.mSuccessStatus;
    msg=obj.mErrorMsg;
end

function status=getCompatStatus(obj)
    switch(obj.mCompatStatus)
    case Sldv.CompatStatus.DV_COMPAT_COMPATIBLE
        status=true;

    case Sldv.CompatStatus.DV_COMPAT_PARTIALLY_SUPPORTED
        status=strcmp(obj.mTestComp.activeSettings.AutomaticStubbing,'on');

    otherwise
        status=false;
    end
end

function restoreActiveSettings(obj,settingToRestore,restoreValue)
    obj.mTestComp.activeSettings.(settingToRestore)=restoreValue;
end
