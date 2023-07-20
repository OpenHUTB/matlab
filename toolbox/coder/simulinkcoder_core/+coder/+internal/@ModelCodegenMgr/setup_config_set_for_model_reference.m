function setup_config_set_for_model_reference(h,onlySetupSimTargetConfigSet)

































    mdlRefTgtType=h.MdlRefBuildArgs.ModelReferenceTargetType;
    mdl=h.ModelName;

    if onlySetupSimTargetConfigSet
        if~isequal(mdlRefTgtType,'SIM')
            DAStudio.error('RTW:makertw:invalidMdlRefTgtType');
        end

        configSet=loc_create_tmp_configset(mdl,mdlRefTgtType);
        h.cleanChange('configset',configSet);
        loc_setup_config_set_for_mdl_ref_sim_target(mdl,configSet);





        hTflControl=get_param(mdl,'SimTargetFcnLibHandle');
        set_param(mdl,'TargetFcnLibHandle',hTflControl);
    else
        reportConfigSetMdlRefIncompat=true;
        reportParentChildConfigSetIncompat=true;

        rtwTargetType=strtok(get_param(mdl,'SystemTargetFile'),'.');



        if isequal(rtwTargetType,'accel')&&~isequal(mdlRefTgtType,'NONE')
            DAStudio.error('Simulink:slbuild:AccelTargetFileNotAllowedForModelRefTarget',mdl);
        end

        if isequal(mdlRefTgtType,'NONE')



            isSimBuild=sl('isSimulationBuild',mdl,mdlRefTgtType);
            if isSimBuild
                return;
            end





            minfo=coder.internal.infoMATFileMgr('load','minfo',mdl,mdlRefTgtType);
            allMdlRefs=unique([reshape(minfo.modelRefs,1,length(minfo.modelRefs)),...
            reshape(minfo.protectedModelRefs,1,length(minfo.protectedModelRefs))]);
            if isempty(allMdlRefs)
                return;
            end




            mdlRefTgtType='RTW';



            reportConfigSetMdlRefIncompat=false;

        end


        if isequal(mdlRefTgtType,'SIM')


            configSet=getActiveConfigSet(mdl);
        else
            [configSet,origConfigSet]=loc_create_tmp_configset(mdl,mdlRefTgtType);
        end





        if isequal(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW')
            h.cleanChange('configset',configSet);
        end


        if isequal(mdlRefTgtType,'SIM')


            reportParentChildConfigSetIncompat=false;

            loc_setup_config_set_for_mdl_ref_sim_target(mdl,configSet);
        end

        if(isequal(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')||...
            isequal(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW'))
            set_param(configSet,'RTWVerbose',h.MdlRefBuildArgs.Verbose);
        end







        loc_check_and_massage_configset(mdl,...
        mdlRefTgtType,...
        reportConfigSetMdlRefIncompat,...
        h.MdlRefBuildArgs,...
        configSet);



        if reportParentChildConfigSetIncompat
            info=coder.internal.infoMATFileMgr('load','minfo',mdl,h.MdlRefBuildArgs.ModelReferenceTargetType);
            mdlRefs=unique([reshape(info.modelRefs,1,length(info.modelRefs)),...
            reshape(info.protectedModelRefs,1,length(info.protectedModelRefs))]);
            nMdlRefs=length(mdlRefs);

            mdlRefConfigSets=cell(size(mdlRefs));

            for i=1:nMdlRefs
                mdlRef=mdlRefs{i};
                coder.internal.modelRefUtil(mdlRef,'setupFolderCacheForReferencedModel',mdl);
                bi=coder.internal.infoMATFileMgr('load','binfo',mdlRef,...
                mdlRefTgtType);
                if isempty(bi)
                    matFileName=coder.internal.infoMATFileMgr...
                    ('getMatFileName','binfo',mdlRef,mdlRefTgtType);


                    msg=message('RTW:buildProcess:infoMATFileMgrMatFileNotFound',...
                    matFileName);
                    error(msg);
                end
                mdlRefConfigSet=bi.configSet;
                mdlRefConfigSets{i}=mdlRefConfigSet;

                childStatesLogging='off';
                if(bi.areStatesLogged)
                    childStatesLogging='on';
                end

                parentStatesLogging='off';
                if((strcmp(get_param(mdl,'SaveState'),'on')||...
                    strcmp(get_param(mdl,'SaveFinalState'),'on'))&&...
                    strcmp(get_param(mdl,'ModelReferenceMatFileLogging'),'on'))
                    parentStatesLogging='on';
                end

                if~isequal(parentStatesLogging,childStatesLogging)
                    topIdentifier='Simulink:slbuild:topChildMdlParamMismatch';
                    topMessage=DAStudio.message(topIdentifier,...
                    get_param(mdl,'Name'),mdlRef);
                    topException=MException(topIdentifier,'%s',topMessage);

                    subIdentifier='Simulink:slbuild:reportStateLoggingErr';

                    saveStateUIInfo=slprivate('slCSProp2UI',configSet,[],'SaveState');
                    saveFinalStateUIInfo=slprivate('slCSProp2UI',configSet,[],'SaveFinalState');
                    matFileLoggingUIInfo=slprivate('slCSProp2UI',configSet,[],'MatFileLogging');

                    if~isempty(matFileLoggingUIInfo)&&matFileLoggingUIInfo.Visible
                        subMessage=DAStudio.message(subIdentifier,...
                        parentStatesLogging,childStatesLogging,...
                        saveStateUIInfo.Prompt,saveStateUIInfo.Path,...
                        saveFinalStateUIInfo.Prompt,saveFinalStateUIInfo.Path,...
                        matFileLoggingUIInfo.Prompt,matFileLoggingUIInfo.Path);
                    else
                        subMessage=DAStudio.message([subIdentifier,'MatFileLoggingAlwaysOn'],...
                        parentStatesLogging,childStatesLogging,...
                        saveStateUIInfo.Prompt,saveStateUIInfo.Path,...
                        saveFinalStateUIInfo.Prompt,saveFinalStateUIInfo.Path);
                    end

                    subException=MException(subIdentifier,'%s',subMessage);
                    topException=topException.addCause(subException);
                    throw(topException);
                end


                csComp=Simulink.ModelReference.internal.configset.ParentChildComparator();
                csComp.compare(mdl,configSet,mdlRef,mdlRefConfigSet,h.MdlRefBuildArgs.ModelReferenceTargetType);
                csComp.report(origConfigSet);
            end
        end
    end
end



function loc_setup_config_set_for_mdl_ref_sim_target(mdl,ioConfigSet)






    param='EmbeddedCoderDictionary';
    value=get_param(mdl,param);
    c=onCleanup(@()ioConfigSet.setProp(param,value));

    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(mdl);
    if isequal(mappingType,'SimulinkCoderCTarget')
        set_param(mdl,'UseInactiveGRTMappings','on');
    elseif isequal(mappingType,'AutosarTarget')
        set_param(mdl,'UseInactiveAUTOSARMappings','on');
    elseif isequal(mappingType,'CppModelMapping')
        set_param(mdl,'UseInactiveCPPMappings','on');

    elseif~strcmp(get_param(mdl,'SystemTargetFile'),'modelrefsim.tlc')
        set_param(mdl,'UseInactiveGRTMappings','off');
        set_param(mdl,'UseInactiveAUTOSARMappings','off');
        set_param(mdl,'UseInactiveCPPMappings','off');
    end



    ioConfigSet.reenableAllProps;


    TLCDebug=get_param(ioConfigSet,'TLCDebug');
    RetainRTWFile=get_param(ioConfigSet,'RetainRTWFile');
    TLCAssert=get_param(ioConfigSet,'TLCAssert');
    TLCCov=get_param(ioConfigSet,'TLCCoverage');
    TLCProfiler=get_param(ioConfigSet,'ProfileTLC');
    RDF=get_param(ioConfigSet,'RemoveDisableFunc');
    RRF=get_param(ioConfigSet,'RemoveResetFunc');


    ignoreCSC='off';







    if isValidParam(ioConfigSet,'CombineOutputUpdateFcns')&&...
        (strcmp(get_param(ioConfigSet,'AdvancedOptControl'),'-SLCI'))
        combineOutputUpdate=get_param(ioConfigSet,'CombineOutputUpdateFcns');
    else
        combineOutputUpdate='off';
    end


    rtw=Simulink.RTWCC('ert.tlc');
    if(slfeature('ModelReferenceHonorsSimTargetLang')>0)
        rtw.TargetLang=ioConfigSet.getComponent('Simulation Target').SimTargetLang;
    end

    if strcmpi(rtw.TargetLang,'C++')
        rtw.DLTargetLibrary='mkl-dnn';
        if strcmp(ioConfigSet.getComponent('Simulation Target').GPUAcceleration,'on')
            DAStudio.warning('RTW:buildProcess:gpuAccelerationNotSupportedForModelRefSim');
        end
    end

    rtw.SystemTargetFile='modelrefsim.tlc';
    rtw.TemplateMakefile='modelrefsim_default_tmf';
    rtw.MakeCommand='make_rtw';
    rtw.RetainRTWFile=RetainRTWFile;
    rtw.TLCDebug=TLCDebug;
    rtw.TLCAssert=TLCAssert;
    rtw.TLCCoverage=TLCCov;
    rtw.ProfileTLC=TLCProfiler;
    rtw.BasicTypes='classic';

    if strcmp(get_param(ioConfigSet,'SupportModelReferenceSimTargetCustomCode'),'on')
        rtw.RTWUseSimCustomCode='on';
    end




    loggingFmt=get_param(ioConfigSet,'SignalLoggingSaveFormat');
    if strcmp(loggingFmt,'ModelDataLogs')
        rtw.IncludeBusHierarchyInRTWFileBlockHierarchyMap='on';
    end


    ert=Simulink.ERTTargetCC;
    ert.CombineOutputUpdateFcns=combineOutputUpdate;
    ert.GenerateSampleERTMain='off';
    ert.RTWCAPISignals='on';
    ert.RTWCAPIStates='on';
    ert.SupportNonInlinedSFcns='on';
    ert.SupportContinuousTime='on';
    ert.RemoveDisableFunc=RDF;
    ert.RemoveResetFunc=RRF;



    ert.ERTSrcFileBannerTemplate='';
    ert.ERTHdrFileBannerTemplate='';
    ert.ERTDataSrcFileTemplate='';
    ert.ERTDataHdrFileTemplate='';
    ert.ERTCustomFileTemplate='';






    if get_param(ioConfigSet,'TargetLang')==rtw.TargetLang
        ert.TargetLangStandard=get_param(ioConfigSet,'TargetLangStandard');
    else
        if strcmpi(rtw.TargetLang,'C++')
            ert.TargetLangStandard='C++11 (ISO)';
        else
            ert.TargetLangStandard='C99 (ISO)';
        end
    end
    rtw.attachComponent(ert);


    cap=rtw.getComponent('Code Appearance');


    cap.GenerateComments='off';
    cap.IgnoreCustomStorageClasses=ignoreCSC;
    cap.MaxIdLength=128;
    if strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'off')
        cap.ObfuscateCode=1;
    end



    tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
    lutObjStructOrderParamExists=tgt.hasProp('LookupTableObjectStructAxisOrder');
    if lutObjStructOrderParamExists
        oldConfigSetLutObjStructAxisOrder=tgt.getProp('LookupTableObjectStructAxisOrder');
    end


    tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
    lutObjExplicitValuesParameterOrderParamExists=tgt.hasProp('LUTObjectStructOrderExplicitValues');
    if lutObjExplicitValuesParameterOrderParamExists
        oldConfigSetLutObjExplicitValuesStructParameterOrder=tgt.getProp('LUTObjectStructOrderExplicitValues');
    end


    tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
    lutObjEvenSpacingParameterOrderParamExists=tgt.hasProp('LUTObjectStructOrderEvenSpacing');
    if lutObjEvenSpacingParameterOrderParamExists
        oldConfigSetLutObjEvenSpacingStructParameterOrder=tgt.getProp('LUTObjectStructOrderEvenSpacing');
    end


    ioConfigSet.attachComponent(rtw);


    hw=ioConfigSet.getComponent('Hardware Implementation');
    slprivate('setHardwareDevice',hw,'Target','MATLAB Host');


    opt=ioConfigSet.getComponent('Optimization');
    set_param(opt,'ZeroInternalMemoryAtStartup','on');
    set_param(opt,'ZeroExternalMemoryAtStartup','on');
    set_param(opt,'InitFltsAndDblsToZero','on');
    set_param(opt,'NoFixptDivByZeroProtection','off');
    set_param(opt,'EfficientFloat2IntCast','off');
    set_param(opt,'EfficientMapNaN2IntZero','off');
    set_param(opt,'UseSpecifiedMinMax','off');



    if(isempty(get_param(mdl,'ProtectedModelCreator')))
        sigLogValue='on';
    else
        sigLogValue='off';
    end
    set_param(ioConfigSet,'SignalLogging',sigLogValue);

    if lutObjStructOrderParamExists

        tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
        set_param(tgt,'LookupTableObjectStructAxisOrder',oldConfigSetLutObjStructAxisOrder);
    end
    if lutObjExplicitValuesParameterOrderParamExists

        tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
        set_param(tgt,'LUTObjectStructOrderExplicitValues',oldConfigSetLutObjExplicitValuesStructParameterOrder);
    end
    if lutObjEvenSpacingParameterOrderParamExists

        tgt=ioConfigSet.getComponent('Code Generation').getComponent('Target');
        set_param(tgt,'LUTObjectStructOrderEvenSpacing',oldConfigSetLutObjEvenSpacingStructParameterOrder);
    end
end




function loc_check_and_massage_configset(iMdl,...
    iMdlRefTgtType,...
    iReportIncompat,...
    mdlRefBuildArgs,...
    configSet)












    origConfigSet=getActiveConfigSet(iMdl);
    dataComponent=origConfigSet.getComponent('Data Import/Export');
    RTWComponent=origConfigSet.getComponent('Code Generation');
    targetComponent=RTWComponent.getComponent('Target');
    turnOnRTWCAPIStates=false;

    if((strcmp(dataComponent.SaveState,'on')||...
        strcmp(dataComponent.SaveFinalState,'on'))&&...
        strcmp(targetComponent.MatFileLogging,'on'))
        turnOnRTWCAPIStates=true;
    end







    set_param(iMdl,'ModelReferenceMatFileLogging',targetComponent.MatFileLogging);






    if strcmp(mdlRefBuildArgs.ModelReferenceTargetType,'RTW')
        if mdlRefBuildArgs.BaGenerateCodeOnly
            genCodeOnlyValue='on';
        else
            genCodeOnlyValue='off';
        end
        set_param(iMdl,'GenCodeOnly',genCodeOnlyValue);
    end


    configSet.checkMdlRefCompliance(iMdlRefTgtType,...
    iReportIncompat,...
    get_param(iMdl,'Name'));




    newRTW=configSet.getComponent('Code Generation');
    newTarget=newRTW.getComponent('Target');
    if newTarget.hasProp('RTWCAPIStates')
        if turnOnRTWCAPIStates
            newTarget.setProp('RTWCAPIStates','on');
        end
    else
        if turnOnRTWCAPIStates
            MSLDiagnostic('RTW:buildProcess:stateLoggingNotSupported').reportAsWarning;
        end
    end
end



function[oConfigSet,oldConfigSet]=loc_create_tmp_configset(iMdl,mdlRefTgtType)

    oldConfigSet=getActiveConfigSet(iMdl);



    oldConfigSet.evalParams();



    oConfigSet=oldConfigSet.copy;
    if isequal(mdlRefTgtType,'SIM')
        oConfigSet.reenableAllProps;
    end

    base_name=['ModelReference_',oConfigSet.Name];
    oConfigSet.Name=base_name;

    idx=1;
    csName=getConfigSet(iMdl,oConfigSet.Name);
    while~isempty(csName)
        oConfigSet.Name=[base_name,num2str(idx)];
        csName=getConfigSet(iMdl,oConfigSet.Name);
        idx=idx+1;
    end
end



