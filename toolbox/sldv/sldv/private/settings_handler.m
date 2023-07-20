function settingsCache=settings_handler(modelH,method,varargin)





    if ischar(modelH)
        modelH=get_param(modelH,'Handle');
    end

    settingsCache=struct;




    try
        if(nargin>2)&&~isempty(varargin{1})
            settingsCache=varargin{1};
        end

        switch(lower(method))
        case 'store'


            blockReplacementApplied=isBlockReplacementApplied(varargin{2});
            settingsCache.dirtyBef=get_param(modelH,'Dirty');
            settingsCache.oldConfigSet=getActiveConfigSet(modelH);
            settingsCache.oldAutoSaveState=get_param(0,'AutoSaveOptions');
            [analysisparams,tunableParamsForDV]=i_get_analyzis_params(modelH,varargin{2});
            params=[analysisparams,i_get_cov_params(modelH),i_get_warning_params(blockReplacementApplied)];
            settingsCache.params=Sldv.utils.settingsValueHandler(params,modelH,true);
            settingsCache.RTWFcnClass=get_param(modelH,'RTWFcnClass');
            settingsCache.BaseWsParamConfiguration=...
            struct('DvTunableParamNames',{''},...
            'Params',{''},'SimulinkParams',{''},'UpdatedSimulinkParamNames',{''},...
            'SimulinkLUTs',{''},'UpdatedSimulinkLUTNames',{''},...
            'SimulinkBrkpts',{''},'UpdatedSimulinkBrkptNames',{''});
            settingsCache.ModelWsParamConfiguration=...
            struct('DvTunableParamNames',{''},...
            'Params',{''},'SimulinkParams',{''},'UpdatedSimulinkParamNames',{''},...
            'SimulinkLUTs',{''},'UpdatedSimulinkLUTNames',{''},...
            'SimulinkBrkpts',{''},'UpdatedSimulinkBrkptNames',{''});
            settingsCache.BaseWsParamConfiguration.DvTunableParamNames=tunableParamsForDV;
            settingsCache.features=Sldv.utils.settingsValueHandler(i_get_analyzis_features,'',true);
            settingsCache.RTWGenSettings=get_param(modelH,'RTWGenSettings');
            settingsCache.ArrayLayout=get_param(modelH,'ArrayLayout');
            settingsCache.RowMajorDimensionSupport=get_param(modelH,'RowMajorDimensionSupport');
            settingsCache.startupVariantBlkHs=varargin{3};
        case 'store_wsparams'
            [settingsCache.BaseWsParamConfiguration,...
            settingsCache.ModelWsParamConfiguration]=i_get_parameters(modelH,settingsCache);
        case 'store_blockrep_gencov'
            settingsCache.dirtyBef=get_param(modelH,'Dirty');
            settingsCache.oldConfigSet=getActiveConfigSet(modelH);
            params=[i_get_cov_params_blockrep_gencov(modelH),i_get_warning_params(false)];
            settingsCache.params=Sldv.utils.settingsValueHandler(params,modelH,true);
        case 'store_checksum'
            settingsCache.dirtyState=get_param(modelH,'Dirty');
            settingsCache.oldConfigSet=getActiveConfigSet(modelH);
            params={{'AssertionControl','EnableAll'}};
            settingsCache.params=Sldv.utils.settingsValueHandler(params,modelH,true);
        case 'init_coverage'






            covParams=i_get_cov_params(modelH,varargin{2});
            blockReplacementApplied=isBlockReplacementApplied(varargin{2});
            util_setupautosave;
            settingsCache=i_settings_setup(modelH,settingsCache);
            compList={'Real-Time Workshop','Optimization'};
            i_attach_default_component(modelH,compList);
            i_configure_hardware_params(modelH);
            warningParams=i_get_warning_params(blockReplacementApplied);
            params=[covParams,warningParams];
            Sldv.utils.settingsValueHandler(params,modelH,false);
        case 'init_coverage_blockrep_gencov'
            covParams=i_get_cov_params_blockrep_gencov(modelH);
            settingsCache=i_settings_setup(modelH,settingsCache);
            warningParams=i_get_warning_params(false);
            params=[covParams,warningParams];
            Sldv.utils.settingsValueHandler(params,modelH,false);
        case 'init_checksum'
            settingsCache=i_settings_setup(modelH,settingsCache);
            params={{'AssertionControl','EnableAll'}};
            settingsCache.params=Sldv.utils.settingsValueHandler(params,modelH,false);
            set_param(modelH,'Dirty','off');
        case 'init_analyzis'

            testcomp=varargin{2};
            if testcomp.forcedTurnOnRelationalBoundary
                testcomp.activeSettings.IncludeRelationalBoundary='on';
            end
            params=i_get_analyzis_params(modelH,testcomp,settingsCache);
            Sldv.utils.settingsValueHandler(params,modelH,false,testcomp);
            Sldv.utils.settingsValueHandler(i_get_analyzis_features,'',false);
            if~testcomp.analysisInfo.strictBusErros



                Sldv.DataUtils.set_cache_compiled_bus(modelH,'on');
            else


                set_param(modelH,'StrictBusMsg',...
                findStoredValue(settingsCache,'StrictBusMsg'));
            end


            [~,genSettings]=coder.internal.getSTFInfo(modelH);
            genSettings.GenRTModel='0';
            set_param(modelH,'RTWGenSettings',genSettings);
            set_param(modelH,'ArrayLayout','Column-major');
            set_param(modelH,'RowMajorDimensionSupport','off');
            i_set_simview(testcomp.verifSubsys,'off');
            i_init_targetfunctionlib(modelH);
            i_set_storage_class_simulink_parameter(settingsCache,modelH);
            set_param(modelH,'RTWFcnClass',[]);


















            set_param(modelH,'PreserveIfCondition','on');
            i_set_startupvariantblks_to_code_compile(settingsCache.startupVariantBlkHs)
        case 'restore'
            if isempty(fields(settingsCache))
                return;
            end
            testcomp=varargin{2};
            if~isempty(testcomp)
                if testcomp.forcedTurnOnRelationalBoundary
                    testcomp.activeSettings.IncludeRelationalBoundary='off';
                end
                i_set_simview(testcomp.verifSubsys,'on');
            end
            Sldv.utils.settingsValueHandler(settingsCache.params,modelH,false);
            Sldv.utils.settingsValueHandler(settingsCache.features,'',false);
            set_param(modelH,'RTWGenSettings',settingsCache.RTWGenSettings);
            set_param(modelH,'ArrayLayout',settingsCache.ArrayLayout);
            set_param(modelH,'RowMajorDimensionSupport',settingsCache.RowMajorDimensionSupport);
            i_settings_restore(modelH,settingsCache);
            i_retsore_storage_class_simulink_parameter(settingsCache,modelH);
            restore_startup_variant_blocks(settingsCache.startupVariantBlkHs);
            set_param(0,'AutoSaveOptions',settingsCache.oldAutoSaveState);
            set_param(modelH,'TargetFcnLibHandle',[]);
            set_param(modelH,'RTWFcnClass',settingsCache.RTWFcnClass);
            set_param(modelH,'Dirty',settingsCache.dirtyBef);





            restore_global_ws_unedit_status(modelH);
        case 'restore_blockrep_gencov'


            Sldv.utils.settingsValueHandler(settingsCache.params,modelH,false);
            if isfield(settingsCache,'features')
                Sldv.utils.settingsValueHandler(settingsCache.features,'',false);
            end
            i_settings_restore(modelH,settingsCache);
            set_param(modelH,'Dirty',settingsCache.dirtyBef);
        case 'restore_checksum'
            Sldv.utils.settingsValueHandler(settingsCache.params,modelH,false);
            i_settings_restore(modelH,settingsCache);
            set_param(modelH,'Dirty',settingsCache.dirtyState);
        case 'restore_global_ws'





            restore_global_ws_unedit_status(modelH);
        otherwise
            error(message('Sldv:Settings:UnknownMethod'));
        end

    catch Mex %#ok<NASGU>
    end
end

function p=i_get_cov_params(modelH,testcomp)
    if nargin<2
        testcomp=[];
    end

    p={};
    if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        p{end+1}={'RecordCoverage','off'};
        if slfeature('RAVarSizeMLArray')>0
            p{end+1}={'SupportVariableSizeSignals','on'};
        end
    else
        p{end+1}={'RecordCoverage','on'};
        if slfeature('DVVarSizeMLArray')>0
            p{end+1}={'SupportVariableSizeSignals','on'};
        end
    end
    p{end+1}={'covPath','/'};
    if strcmpi(get_param(modelH,'CovLogicBlockShortCircuit'),'on')
        p{end+1}={'covMetricSettings','dcmes'};
    else
        p{end+1}={'covMetricSettings','dcme'};
    end

    p{end+1}={'CovExternalEmlEnable','on'};
    p{end+1}={'CovHtmlReporting','off'};
    p{end+1}={'CovSaveSingleToWorkspaceVar','off'};
    p{end+1}={'CovSaveCumulativeToWorkspaceVar','off'};
    p{end+1}={'SimulationMode','normal'};
    p{end+1}={'SaveFormat','StructureWithTime'};
    p{end+1}={'MinMaxOverflowLogging','ForceOff'};

    if strcmp(get_param(modelH,'BooleanDataType'),'off')






        p{end+1}={'BooleanDataType','off'};
    end




    if exist('fbt_testing_active','file')&&fbt_testing_active()
        blrv='off';
    else



        blrv='on';
    end
    p{end+1}={'BlockReduction',blrv};

    sfcnEnable='on';
    if~isempty(testcomp)
        sfcnEnable=testcomp.activeSettings.SFcnSupport;
    end
    p{end+1}={'CovSFcnEnable',sfcnEnable};
end

function p=i_get_cov_params_blockrep_gencov(modelH)
    p={};
    p{end+1}={'RecordCoverage','on'};
    p{end+1}={'covPath','/'};
    if strcmpi(get_param(modelH,'CovLogicBlockShortCircuit'),'on')
        p{end+1}={'covMetricSettings','dcmes'};
    else
        p{end+1}={'covMetricSettings','dcme'};
    end
    p{end+1}={'covModelRefEnable','on'};
    p{end+1}={'CovExternalEmlEnable','on'};
    p{end+1}={'CovHtmlReporting','off'};
    p{end+1}={'CovSaveSingleToWorkspaceVar','off'};
    p{end+1}={'CovSaveCumulativeToWorkspaceVar','off'};
    p{end+1}={'SimulationMode','normal'};
    p{end+1}={'SaveFormat','StructureWithTime'};
    p{end+1}={'MinMaxOverflowLogging','ForceOff'};





    p{end+1}={'SaveState','off'};



    if exist('fbt_testing_active','file')&&fbt_testing_active()
        blrv='off';
    else



        blrv='on';
    end
    p{end+1}={'BlockReduction',blrv};
end

function[p,tunableParams]=i_get_analyzis_params(modelH,~,settingsCache)
    if nargin<3
        settingsCache=[];
    end

    p={};
    tunableParams={''};
    p{end+1}={'RecordCoverage','off'};
    p{end+1}={'RTWInlineParameters','on'};
    p{end+1}={'InlineInvariantSignals','off'};
    p{end+1}={'RTWExternMdlXlate',1};
    p{end+1}={'RollThreshold',5};
    p{end+1}={'OptimizeBlockIOStorage','off'};
    p{end+1}={'SupportContinuousTime','on'};
    p{end+1}={'SaveCompleteFinalSimState','off'};
    p{end+1}={'SupportNonInlinedSFcns','on'};
    p{end+1}={'SFMachineParentedDataDiag','error'};



    p{end+1}={'EnableTagging','on'};

    modelParametersToHonor={'ConditionallyExecuteInputs','UseDivisionForNetSlopeComputation',...
    'SignalRangeChecking','IntegerOverflowMsg','UseRowMajorAlgorithm'};

    if isempty(settingsCache)
        for idx=1:length(modelParametersToHonor)
            p{end+1}={modelParametersToHonor{idx},get_param(modelH,modelParametersToHonor{idx})};%#ok<AGROW>
        end
    else
        for i=1:length(settingsCache.params)
            if any(strcmp(settingsCache.params{i}{1},modelParametersToHonor))
                p{end+1}=settingsCache.params{i};%#ok<AGROW>
            end
        end
    end



    singleTaskingConfigParams=[];
    singleTaskingConfigParams=...
    get_single_tasking_params(modelH,singleTaskingConfigParams);
    paramNames=fieldnames(singleTaskingConfigParams);
    for i=1:length(paramNames)
        p{end+1}={paramNames{i},singleTaskingConfigParams.(paramNames{i})};
    end








    p{end+1}={'StrictBusMsg','ErrorLevel1'};




    p{end+1}={'SupportNonFinite','off'};




    params=sldvshareprivate('parameters','getAll',modelH);
    if~isempty(params)
        tVars=fieldnames(params);
        tunableParams=tVars;
        [tv,tvStorageClass,tvTypeQualifier]=build_tunable(tVars,settingsCache,modelH);
        p{end+1}={'TunableVars',tv};
        p{end+1}={'TunableVarsStorageClass',tvStorageClass};
        p{end+1}={'TunableVarsTypeQualifier',tvTypeQualifier};
        p{end+1}={'ParameterTunabilityLossMsg','error'};
    else
        if sldvshareprivate('util_is_analyzing_for_fixpt_tool')


            storageClassSetting=get_param(modelH,'TunableVarsStorageClass');
            storageClassSetting=strrep(storageClassSetting,'ImportedExternPointer','ImportedExtern');
            storageClassSetting=strrep(storageClassSetting,'ExportedGlobal','ImportedExtern');
            storageClassSetting=strrep(storageClassSetting,'Auto','ImportedExtern');
            p{end+1}={'TunableVarsStorageClass',storageClassSetting};
            typeQualifierSetting=get_param(modelH,'TunableVarsTypeQualifier');
            typeQualifierSetting=typeQualifierSetting(strfind(typeQualifierSetting,','));
            p{end+1}={'TunableVarsTypeQualifier',typeQualifierSetting};
            p{end+1}={'ParameterTunabilityLossMsg','error'};
        else
            p{end+1}={'TunableVars',''};
            p{end+1}={'TunableVarsStorageClass',''};
            p{end+1}={'TunableVarsTypeQualifier',''};
        end
    end














    p{end+1}={'AssertionControl','EnableAll'};


    p{end+1}={'AllowSymbolicDim','off'};
end

function p=i_get_warning_params(blockReplacementApplied)

    p={};
    p{end+1}={'InheritedTsInSrcMsg','none'};
    if blockReplacementApplied
        p{end+1}={'CheckSSInitialOutputMsg','off'};
    end
end

function f=i_get_analyzis_features()

    f={};
    f{end+1}={'feature','EngineInterface',Simulink.EngineInterfaceVal.byFiat};




    f{end+1}={'feature','SetParamOnLinks',3};
    f{end+1}={'sf','Feature','Coder Unification',2};




    if slavteng('feature','debugLevel')>=8
        tv=6;
    else
        tv=1;
    end
    f{end+1}={'slfeature','RTWCGIR',tv};
    f{end+1}={'slfeature','CGIRSanityChecker',0};
end

function i_settings_restore(modelH,settingsCache)
    currConfigSet=getActiveConfigSet(modelH);
    if isa(settingsCache.oldConfigSet,'Simulink.ConfigSetRef')||...
        (currConfigSet~=settingsCache.oldConfigSet)
        setActiveConfigSet(modelH,settingsCache.oldConfigSet.Name);
        if isfield(settingsCache,'oldConfigSetNameChangeDisabled')&&settingsCache.oldConfigSetNameChangeDisabled
            srcOldConfigSet=sldvshareprivate('mdl_get_configset',modelH);
            srcOldConfigSet.setPropEnabled('Name',false);
        end
        detachConfigSet(modelH,currConfigSet.Name);
    end
end

function settingsCache=i_settings_setup(modelH,settingsCache)
    oldConfigSet=sldvshareprivate('mdl_get_configset',modelH);
    settingsCache.oldConfigSetNameChangeDisabled=~oldConfigSet.getPropEnabled('Name');
    oldConfigSet.setPropEnabled('Name',true);
    newConfigSet=attachConfigSetCopy(modelH,oldConfigSet,true);
    newConfigSet.Name='SLDV Temporary Config Set';
    setActiveConfigSet(modelH,newConfigSet.Name);
end

function i_set_simview(blks,value)
    slfeature('SetParamOnLinks',3);
    for blk=blks(:)'
        if ishandle(blk)&&~strcmp(get_param(blk,'StaticLinkStatus'),'resolved')
            set_param(blk,'SimViewingDevice',value);
        end
    end
end

function i_attach_default_component(modelH,compList)
    configSet=getActiveConfigSet(modelH);
    rtwccCustomParams={'TemplateMakefile',...
    'TargetLang','CustomHeaderCode','CustomSourceCode','CustomInitializer',...
    'CustomTerminator','CustomInclude','CustomLibrary','CustomSource'};

    ecd=configSet.get_param('EmbeddedCoderDictionary');
    c=onCleanup(@()configSet.set_param('EmbeddedCoderDictionary',ecd));

    origRtwccCustomConfigVals=cell(length(rtwccCustomParams),1);
    for i=1:length(rtwccCustomParams)
        origRtwccCustomConfigVals{i}=get_param(configSet,rtwccCustomParams{i});
    end


    [srcModelMapping,srcMappingType]=Simulink.CodeMapping.getCurrentMapping(modelH);

    dcs=Simulink.ConfigSet;
    dcs.switchTarget('ert.tlc',[]);


    if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
        dcs.set_param('InlineParams',configSet.get_param('InlineParams'));
    end
    dcs.set_param('DefaultUnderspecifiedDataType',configSet.get_param('DefaultUnderspecifiedDataType'));
    dcs.set_param('UseRowMajorAlgorithm',configSet.get_param('UseRowMajorAlgorithm'));
    for idx=1:length(compList)
        pn=compList{idx};
        if(dcs.getComponentIndex(pn)~=0)&&...
            (configSet.getComponentIndex(pn)~=0)
            dcc=dcs.getComponent(pn);
            dccCopy=copy(dcc);
            if(strcmp(pn,'Real-Time Workshop'))
                for i=1:length(rtwccCustomParams)
                    dccCopy.set_param(rtwccCustomParams{i},origRtwccCustomConfigVals{i});
                end
            end
            configSet.attachComponent(dccCopy);
        end
    end



    if~isempty(srcModelMapping)&&...
        isequal(srcMappingType,'SimulinkCoderCTarget')

        [dstModelMapping,dstMappingType]=Simulink.CodeMapping.getCurrentMapping(modelH);
        if isempty(dstModelMapping)&&...
            isequal(dstMappingType,'CoderDictionary')

            coder.mapping.internal.copyInactiveCodeMappings(modelH);
        end
    end

end


function[tv,tvS,tvT]=build_tunable(c,settingsCache,modelH)
    if nargin<2
        settingsCache=[];
    end
    if~isempty(settingsCache)&&...
        ~isempty(settingsCache.BaseWsParamConfiguration.SimulinkParams)
        referencedSimulinkParameterNames=...
        cell(1,length(settingsCache.BaseWsParamConfiguration.SimulinkParams));
        for idx=1:length(settingsCache.BaseWsParamConfiguration.SimulinkParams)
            referencedSimulinkParameterNames{idx}=...
            settingsCache.BaseWsParamConfiguration.SimulinkParams{idx}.Name;
        end
        referencedTunableSimulinkParameterNames=...
        intersect(referencedSimulinkParameterNames,...
        settingsCache.BaseWsParamConfiguration.DvTunableParamNames);
    else
        referencedTunableSimulinkParameterNames={};
    end
    tv='';
    tvS='';
    tvT='';
    if~isempty(c)
        idxToRemove=[];





        for idx=1:length(c)



            if(evalinGlobalScope(modelH,sprintf('isa(%s, ''Simulink.Parameter'');',c{idx})))
                idxToRemove(end+1)=idx;%#ok<AGROW>




















            end
        end
        c(idxToRemove)=[];
    end
    if~isempty(c)
        tv=c{1};
        if any(strcmp(c{1},referencedTunableSimulinkParameterNames))
            tvS='ImportedExtern';
        else
            tvS='Auto';
        end
        for i=2:length(c)
            tv=[tv,', ',c{i}];%#ok<AGROW>
            if any(strcmp(c{i},referencedTunableSimulinkParameterNames))



                tvS=[tvS,', ImportedExtern'];%#ok<AGROW>
            else
                tvS=[tvS,', Auto'];%#ok<AGROW>
            end
            tvT=[tvT,','];%#ok<AGROW>
        end
    end
end

function i_init_targetfunctionlib(modelH)
    set_param(modelH,'CodeReplacementLibrary','SLDV');
    set_param(modelH,'TargetFcnLibHandle',[]);
end

function blockReplacementApplied=isBlockReplacementApplied(testcomp)
    blockReplacementApplied=false;
    if~isempty(testcomp)
        as=testcomp.activeSettings;
        if strcmp(as.BlockReplacement,'on')
            blockReplacementApplied=true;
        end
    end
end

function storedValue=findStoredValue(settingsCache,paramName)
    for idx=1:length(settingsCache.params)
        if strcmp(settingsCache.params{idx}{1},paramName)
            storedValue=settingsCache.params{idx}{2};
            break;
        end
    end
end

function[baseWsParamConfiguration,modelWsParamConfiguration]=i_get_parameters(modelH,settingsCache)
    matlabVarPresentInDataDictionary=false;
    baseWsParamConfiguration=settingsCache.BaseWsParamConfiguration;
    modelWsParamConfiguration=settingsCache.ModelWsParamConfiguration;



    vars=Sldv.xform.RepMdlRefBlkTreeNode.genReferencedVars(modelH,'global');
    for idx=1:length(vars)
        if isa(vars(idx).Value,'Simulink.Parameter')
            baseWsParamConfiguration.SimulinkParams{end+1}=vars(idx);
            if any(strcmp(vars(idx).Name,baseWsParamConfiguration.DvTunableParamNames))
                if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'ImportedExtern')



                    baseWsParamConfiguration.UpdatedSimulinkParamNames{end+1}=...
                    vars(idx).Name;
                end
            elseif~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')








                baseWsParamConfiguration.UpdatedSimulinkParamNames{end+1}=...
                vars(idx).Name;
            end
        elseif isa(vars(idx).Value,'Simulink.LookupTable')
            baseWsParamConfiguration.SimulinkLUTs{end+1}=vars(idx);
            if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')
                baseWsParamConfiguration.UpdatedSimulinkLUTNames{end+1}=...
                vars(idx).Name;
            end
        elseif isa(vars(idx).Value,'Simulink.Breakpoint')
            baseWsParamConfiguration.SimulinkBrkpts{end+1}=vars(idx);
            if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')
                baseWsParamConfiguration.UpdatedSimulinkBrkptNames{end+1}=...
                vars(idx).Name;
            end
        else

            if strcmp(vars(idx).SourceType,'data dictionary')
                matlabVarPresentInDataDictionary=true;
            end
            baseWsParamConfiguration.Params{end+1}=vars(idx);
        end
    end

    if matlabVarPresentInDataDictionary








        sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv_warning',...
        getString(message('Sldv:Parameters:DDMATLABVariableTuningNotSupported')),...
        'Sldv:Parameters:DDMATLABVariableTuningNotSupported');
    end

    vars=Sldv.xform.RepMdlRefBlkTreeNode.genReferencedVars(modelH,'model');
    for idx=1:length(vars)

        if isa(vars(idx).Value,'Simulink.Parameter')
            modelWsParamConfiguration.SimulinkParams{end+1}=vars(idx);
            if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')
                modelWsParamConfiguration.UpdatedSimulinkParamNames{end+1}=...
                vars(idx).Name;
            end
        elseif isa(vars(idx).Value,'Simulink.LookupTable')
            modelWsParamConfiguration.SimulinkLUTs{end+1}=vars(idx);
            if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')
                modelWsParamConfiguration.UpdatedSimulinkLUTNames{end+1}=...
                vars(idx).Name;
            end
        elseif isa(vars(idx).Value,'Simulink.Breakpoint')
            modelWsParamConfiguration.SimulinkBrkpts{end+1}=vars(idx);
            if~strcmp(vars(idx).Value.CoderInfo.StorageClass,'Auto')
                modelWsParamConfiguration.UpdatedSimulinkBrkptNames{end+1}=...
                vars(idx).Name;
            end
        else
            modelWsParamConfiguration.Params{end+1}=vars(idx);
        end
    end
end

function i_set_storage_class_simulink_parameter(settingsCache,modelH)
    baseWsParamConfiguration=settingsCache.BaseWsParamConfiguration;
    for idx=1:length(baseWsParamConfiguration.SimulinkParams)
        if any(strcmp(baseWsParamConfiguration.SimulinkParams{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkParamNames))
            assert(~baseWsParamConfiguration.SimulinkParams{idx}.Value.CoderInfo.HasContext,'Expected objects without context');
            value=baseWsParamConfiguration.SimulinkParams{idx}.Value.copy;
            if any(strcmp(baseWsParamConfiguration.SimulinkParams{idx}.Name,...
                baseWsParamConfiguration.DvTunableParamNames))
                value.CoderInfo.StorageClass='ImportedExtern';
            else



                if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                    value.CoderInfo.StorageClass='ImportedExtern';
                else
                    value.CoderInfo.StorageClass='Auto';
                end
            end
            value.CoderInfo.Identifier='';
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkParams{idx}.Name,value)
        end
    end

    for idx=1:length(baseWsParamConfiguration.SimulinkLUTs)
        if any(strcmp(baseWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkLUTNames))
            assert(~baseWsParamConfiguration.SimulinkLUTs{idx}.Value.CoderInfo.HasContext,'Expected objects without context');
            value=baseWsParamConfiguration.SimulinkLUTs{idx}.Value.copy;

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                value.CoderInfo.StorageClass='ImportedExtern';
            else
                value.CoderInfo.StorageClass='Auto';
            end

            value.CoderInfo.Identifier='';
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkLUTs{idx}.Name,value)
        end
    end

    for idx=1:length(baseWsParamConfiguration.SimulinkBrkpts)
        if any(strcmp(baseWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkBrkptNames))
            assert(~baseWsParamConfiguration.SimulinkBrkpts{idx}.Value.CoderInfo.HasContext,'Expected objects without context');
            value=baseWsParamConfiguration.SimulinkBrkpts{idx}.Value.copy;

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                value.CoderInfo.StorageClass='ImportedExtern';
            else
                value.CoderInfo.StorageClass='Auto';
            end

            value.CoderInfo.Identifier='';
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkBrkpts{idx}.Name,value)
        end
    end

    modelWsParamConfiguration=settingsCache.ModelWsParamConfiguration;
    for idx=1:length(modelWsParamConfiguration.SimulinkParams)
        if any(strcmp(modelWsParamConfiguration.SimulinkParams{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkParamNames))


            value=modelWsParamConfiguration.SimulinkParams{idx}.Value.copy;
            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                value.CoderInfo.StorageClass='ImportedExtern';
            else
                value.CoderInfo.StorageClass='Auto';
            end
            value.CoderInfo.Identifier='';
            mws=get_param(modelWsParamConfiguration.SimulinkParams{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkParams{idx}.Name,value);
        end
    end
    for idx=1:length(modelWsParamConfiguration.SimulinkLUTs)
        if any(strcmp(modelWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkLUTNames))


            value=modelWsParamConfiguration.SimulinkLUTs{idx}.Value.copy;
            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                value.CoderInfo.StorageClass='ImportedExtern';
            else
                value.CoderInfo.StorageClass='Auto';
            end
            value.CoderInfo.Identifier='';
            mws=get_param(modelWsParamConfiguration.SimulinkLUTs{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkLUTs{idx}.Name,value);
        end
    end
    for idx=1:length(modelWsParamConfiguration.SimulinkBrkpts)
        if any(strcmp(modelWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkBrkptNames))


            value=modelWsParamConfiguration.SimulinkBrkpts{idx}.Value.copy;
            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                value.CoderInfo.StorageClass='ImportedExtern';
            else
                value.CoderInfo.StorageClass='Auto';
            end
            value.CoderInfo.Identifier='';
            mws=get_param(modelWsParamConfiguration.SimulinkBrkpts{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkBrkpts{idx}.Name,value);
        end
    end


end

function i_retsore_storage_class_simulink_parameter(settingsCache,modelH)
    baseWsParamConfiguration=settingsCache.BaseWsParamConfiguration;
    modelWsParamConfiguration=settingsCache.ModelWsParamConfiguration;
    for idx=1:length(baseWsParamConfiguration.SimulinkParams)
        if any(strcmp(baseWsParamConfiguration.SimulinkParams{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkParamNames))
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkParams{idx}.Name,...
            baseWsParamConfiguration.SimulinkParams{idx}.Value);
        end
    end
    for idx=1:length(baseWsParamConfiguration.SimulinkLUTs)
        if any(strcmp(baseWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkLUTNames))
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            baseWsParamConfiguration.SimulinkLUTs{idx}.Value);
        end
    end
    for idx=1:length(baseWsParamConfiguration.SimulinkBrkpts)
        if any(strcmp(baseWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            baseWsParamConfiguration.UpdatedSimulinkBrkptNames))
            assigninGlobalScope(modelH,baseWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            baseWsParamConfiguration.SimulinkBrkpts{idx}.Value);
        end
    end


    for idx=1:length(modelWsParamConfiguration.SimulinkParams)
        if any(strcmp(modelWsParamConfiguration.SimulinkParams{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkParamNames))
            mws=get_param(modelWsParamConfiguration.SimulinkParams{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkParams{idx}.Name,...
            modelWsParamConfiguration.SimulinkParams{idx}.Value);
        end
    end
    for idx=1:length(modelWsParamConfiguration.SimulinkLUTs)
        if any(strcmp(modelWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkLUTNames))
            mws=get_param(modelWsParamConfiguration.SimulinkLUTs{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkLUTs{idx}.Name,...
            modelWsParamConfiguration.SimulinkLUTs{idx}.Value);
        end
    end
    for idx=1:length(modelWsParamConfiguration.SimulinkBrkpts)
        if any(strcmp(modelWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            modelWsParamConfiguration.UpdatedSimulinkBrkptNames))
            mws=get_param(modelWsParamConfiguration.SimulinkBrkpts{idx}.Source,'ModelWorkspace');
            mws.assignin(modelWsParamConfiguration.SimulinkBrkpts{idx}.Name,...
            modelWsParamConfiguration.SimulinkBrkpts{idx}.Value);
        end
    end


end

function i_configure_hardware_params(modelH)
    origConfigSet=sldvshareprivate('mdl_get_configset',modelH);
    hParent=getHParent(origConfigSet);

    hardwareParamNameIRValues={...
    {'ProdEqTarget','off'},...
    {'TargetHWDeviceType','Generic->Unspecified (assume 32-bit Generic)'},...
    };


    assert(strcmp(hardwareParamNameIRValues{1}{1},'ProdEqTarget'));

    for idx=1:length(hardwareParamNameIRValues)
        hParent.setPropEnabled(hardwareParamNameIRValues{idx}{1},true);
        set_param(modelH,hardwareParamNameIRValues{idx}{1},hardwareParamNameIRValues{idx}{2})
    end
end

function i_set_startupvariantblks_to_code_compile(startupVariantBlkHs)



    for idx=1:numel(startupVariantBlkHs)
        set_param(startupVariantBlkHs(idx),'variantActivationTime','code compile');
    end
end

function hParent=getHParent(origConfigSet)
    hParent=origConfigSet;
    while~isempty(hParent.getParent)&&isa(hParent.getParent,'Simulink.BaseConfig')
        hParent=hParent.getParent;
    end
end



function restore_global_ws_unedit_status(modelH)


    ddName=get_param(modelH,'DataDictionary');

    if~isempty(ddName)

        try
            wsConn=Simulink.dd.open(ddName);


            if wsConn.hasUnsavedChanges
                wsConn.discardChanges();
            end
        catch Mex %#ok<NASGU>




        end
    end
end

function restore_startup_variant_blocks(startupVariantBlkHs)



    for idx=1:numel(startupVariantBlkHs)
        set_param(startupVariantBlkHs(idx),'variantActivationTime','startup');
    end
end


