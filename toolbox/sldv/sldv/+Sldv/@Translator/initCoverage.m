function initCoverage(obj)






    simLog='';
    parameterSettings=[];
    modelName=obj.mModelToCheckCompatName;
    modelH=obj.mModelToCheckCompatH;
    stubsfcns=obj.mStubsfcns;


    if slfeature('SldvSimFunWithBusArgOut')
        simFunBlks=[];
    else
        simFunBlks=obj.getSimulinkFunctionBlocks;
    end


    if slfeature('SldvPrelookupWithBusArrayOut')
        preLookupBlks=[];
    else
        preLookupBlks=obj.getPreLookupBlocks;
    end

    try
        obj.mTestComp.profileStage('Compilation');
        obj.mTestComp.getMainProfileLogger().openPhase('Compilation');

        [simLog,parameterSettings]=sldvprivate('sldvCompileForCoverage',...
        modelName,obj.mTestComp);
        compiledModelState=onCleanup(@()feval(modelName,[],[],[],'term'));

        obsEntityInCompat=false;
        compatStatus=obj.observerCompileTimeCompatChecks();
        if strcmp('DV_COMPAT_INCOMPATIBLE',compatStatus)
            obsEntityInCompat=true;
            obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
        end

        isVarSized=sldvprivate('mdl_has_vardimsignal',modelH);
        if isVarSized&&~slfeature('DVVarSizeSignal')
            obj.genVarDimError(modelH);
        end

        hasSFcnBus=false;
        for sfunBlk=stubsfcns
            if sldvprivate('blk_has_bus',sfunBlk)&&...
                ~strcmp(get_param(sfunBlk,'Name'),'customAVTBlockSFcn')&&...
                ~sldv.code.sfcn.isSFcnCompatible(get_param(sfunBlk,'FunctionName'))

                obj.genBusSfunStubError(sfunBlk)
                hasSFcnBus=true;
            end
        end


        isMultiTaskIncompat=false;
        cacheSolverMode=cacheSettingVal(obj.mSettingsCache,'SolverMode');
        if(~isempty(cacheSolverMode)&&~strcmp(cacheSolverMode,'SingleTasking'))


















            if(mdl_has_multi_discrete_ts(modelH))


                if(~strcmp(get_param(modelH,'MultiTaskRateTransMsg'),'error'))
                    if~strcmp(cacheSettingVal(obj.mSettingsCache,'AutoInsertRateTranBlk'),'on')

                        isMultiTaskIncompat=true;
                        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
                        sldvshareprivate('avtcgirunsupcollect',...
                        'push',modelH,'sldv',...
                        getString(message('Sldv:Compatibility:MultiTaskUnsupport')),...
                        'Sldv:Compatibility:MultiTaskUnsupport');
                    end
                end
            end
        end


        hasNonfiniteParam=sldvprivate('mdl_check_param_nonfinite_values',modelH);
        if~hasNonfiniteParam


            sldvprivate('mdl_get_params_sample_times',modelH,obj.mTestComp);

            stat=sldvprivate('mdl_get_params_runtime_types',modelH,obj.mTestComp);
            if~stat
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            end
        end

        if~isempty(simFunBlks)





            unsupSimFun=false;

            dataAccessor=Simulink.data.DataAccessor.create(get_param(modelH,'name'));

            for jdx=1:length(simFunBlks)
                simFunBlk=simFunBlks(jdx);



                argOutBlks=find_system(simFunBlk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',Inf,'BlockType','ArgOut');
                for kdx=1:length(argOutBlks)
                    argOutBlk=argOutBlks(kdx);

                    portHandles=get_param(argOutBlk,'PortHandles');
                    inport=portHandles.Inport;

                    compiledPortDataType=get_param(inport,'CompiledPortDataType');
                    compiledPortComplexSignal=get_param(inport,'CompiledPortComplexSignal');

                    [isBus,~]=Sldv.utils.isBusType(compiledPortDataType,dataAccessor);
                    if isBus
                        errMsg=getString(message('Sldv:Compatibility:SimFunWithBusArgOut'));
                        sldvshareprivate('avtcgirunsupcollect','push',simFunBlk,'simulink',errMsg,'Sldv:Compatibility:SimFunWithBusArgOut');
                        unsupSimFun=true;
                    elseif compiledPortComplexSignal
                        errMsg=getString(message('Sldv:Compatibility:SimFunWithComplexArgOut'));
                        sldvshareprivate('avtcgirunsupcollect','push',simFunBlk,'simulink',errMsg,'Sldv:Compatibility:SimFunWithComplexArgOut');
                        unsupSimFun=true;
                    end
                end
            end

            if unsupSimFun
                obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            end
        end

        if~isempty(preLookupBlks)




            unsupPreLookup=false;

            dataAccessor=Simulink.data.DataAccessor.create(get_param(modelH,'name'));

            for jdx=1:length(preLookupBlks)
                preLookupBlk=preLookupBlks(jdx);

                portHandles=get_param(preLookupBlk,'PortHandles');
                outport=portHandles.Outport(1);

                compiledPortDataType=get_param(outport,'CompiledPortDataType');
                [isBus,~]=Sldv.utils.isBusType(compiledPortDataType,dataAccessor);

                if isBus
                    compiledPortDims=get_param(outport,'CompiledPortDimensions');
                    if~isempty(compiledPortDims)&&any(compiledPortDims>1)
                        errMsg=getString(message('Sldv:Compatibility:PreLookupWithBusArayOut'));
                        sldvshareprivate('avtcgirunsupcollect','push',preLookupBlk,'simulink',errMsg,'Sldv:Compatibility:PreLookupWithBusArayOut');
                        unsupPreLookup=true;
                    end
                end
            end

            if unsupPreLookup
                obj.mCompatStatus='DV_COMPAT_INCOMPATIBLE';
            end
        end

        obj.mSettingsCache=...
        sldvprivate('settings_handler',modelH,'store_wsparams',obj.mSettingsCache);

        obj.mTestComp.analysisInfo.Approximations.LookupTables=...
        collect_luts(obj.mModelToCheckCompatH);

        clear compiledModelState;

        obj.mTestComp.profileStage('end');
        obj.mTestComp.getMainProfileLogger().closePhase('Compilation');





        Sldv.utils.switchObsMdlsToStandaloneMode(modelH);

        startCovDataConsistent=sldvprivate('mdl_check_startcovdata',modelH,obj.mTestComp);

        if obsEntityInCompat||~startCovDataConsistent||(isVarSized&&~slfeature('DVVarSizeSignal'))||...
            hasNonfiniteParam||hasSFcnBus||isMultiTaskIncompat

            obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
            obj.logNewLines(obj.html_red(getString(message('Sldv:Setup:ErrorsDuringCompilation'))));
            if obj.mShowUI
                obj.logAll(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
            else
                obj.logAll(simLog);
            end
        end

    catch Mex

        clear compiledModelState;



        obj.logNewLines(obj.html_red(getString(message('Sldv:Setup:ErrorsDuringCompilation'))));
        if isempty(simLog)
            simLog=Mex.message;
            simLog=strrep(simLog,[getString(message('Sldv:Setup:xlate_ErrorUsing')),getString(message('Sldv:Setup:xlate_Sim'))],'');
            id=Mex.identifier;
            mExceptionCauseFlat=sldvshareprivate('util_get_error_causes',Mex);
        else
            id='Sldv:Compatibility:Translation';
            mExceptionCauseFlat={};
        end
        sldvshareprivate('util_add_error_causes',modelH,mExceptionCauseFlat);
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',...
        sprintf('%s',getString(message('Sldv:Setup:CompilingModelFailed',simLog))),id);
        if obj.mShowUI
            obj.logAll(getString(message('Sldv:Setup:ReferDiagnosticsWindow')));
        else
            obj.logAll(simLog);
        end
        obj.mCompatStatus=Sldv.CompatStatus.DV_COMPAT_INCOMPATIBLE;
    end

    if~isempty(parameterSettings)
        parameterNames=fieldnames(parameterSettings);
        for idx=1:length(parameterNames)
            Sldv.utils.settingsValueHandler({{parameterNames{idx},parameterSettings.(parameterNames{idx}).originalvalue}},modelName,false);
        end
    end
end



function val=cacheSettingVal(settingsCache,name)
    val='';
    if isfield(settingsCache,'params')
        allparams=settingsCache.params;
        for idx=1:numel(allparams)
            if strcmp(allparams{idx}{1},name)
                val=settingsCache.params{idx}{2};
                break
            end
        end
    end
end




function out=mdl_has_multi_discrete_ts(modelH)
    mdlSampleTimes=Simulink.BlockDiagram.getSampleTimes(modelH);
    tsTypes={mdlSampleTimes.Annotation};
    isDisc=strncmp('D',tsTypes,1);

    tsDiscVals=[mdlSampleTimes(isDisc).Value];
    tsDiscVals=tsDiscVals(1:2:end);
    out=sum(isfinite(tsDiscVals))>1;
end


















function approx_luts=collect_luts(modelH)

    fxpLUTApprox=slfeature('SLDVApproxFxpLUT');
    approx_luts=[];

    if fxpLUTApprox


        opts={'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','Type','Block',...
        'BlockType','Lookup_n-D','NumberOfTableDimensions','1'};

        aBlks=find_system(modelH,opts{:});


        if~isempty(aBlks)
            for idx=1:length(aBlks)
                blk=aBlks(idx);
                ph=get_param(blk,'PortHandles');
                this_lut.blk=blk;
                Tx_name=get(ph.Inport(1),'CompiledPortAliasedThruDataType');
                To_name=get(ph.Outport,'CompiledPortAliasedThruDataType');



                if~isempty(Tx_name)&&~isempty(To_name)


                    TxType=meta.class.fromName(Tx_name);
                    ToType=meta.class.fromName(To_name);



                    if(isempty(TxType)||~TxType.Enumeration)&&...
                        (isempty(ToType)||~ToType.Enumeration)
                        Tx=numerictype(Tx_name);
                        To=numerictype(To_name);
                        if~isfloat(Tx)&&~isfloat(To)&&...
                            Tx.WordLength<=32&&To.WordLength<=32&&...
                            strcmp(get_param(blk,'ExtrapMethod'),'Clip')&&...
                            strcmp(get_param(blk,'InterpMethod'),'Linear point-slope')
                            this_lut.blk=blk;
                            this_lut.types=[Tx,To];
                            approx_luts=[approx_luts,this_lut];%#ok<AGROW>
                        end
                    end
                end
            end
        end
    end




    opts={'FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','Type','Block',...
    'BlockType','Lookup_n-D','NumberOfTableDimensions','2'};

    aBlks=find_system(modelH,opts{:});

    if~isempty(aBlks)
        for idx=1:length(aBlks)
            blk=aBlks(idx);
            ph=get_param(blk,'PortHandles');
            Tx_name=get(ph.Inport(1),'CompiledPortAliasedThruDataType');
            if numel(ph.Inport)==1
                Ty_name=Tx_name;
            else
                Ty_name=get(ph.Inport(2),'CompiledPortAliasedThruDataType');
            end
            To_name=get(ph.Outport,'CompiledPortAliasedThruDataType');

            this_lut.blk=blk;
            if((strcmp(Tx_name,'double')||strcmp(Tx_name,'single'))&&...
                (strcmp(Ty_name,'double')||strcmp(Ty_name,'single'))&&...
                (strcmp(To_name,'double')||strcmp(To_name,'single')))

                this_lut.types=[];
                approx_luts=[approx_luts,this_lut];%#ok<AGROW>

            elseif fxpLUTApprox&&~isempty(Tx_name)&&~isempty(Ty_name)&&~isempty(To_name)


                TxType=meta.class.fromName(Tx_name);
                TyType=meta.class.fromName(Ty_name);
                ToType=meta.class.fromName(To_name);



                if(isempty(TxType)||~TxType.Enumeration)&&...
                    (isempty(TyType)||~TyType.Enumeration)&&...
                    (isempty(ToType)||~ToType.Enumeration)

                    Tx=numerictype(Tx_name);
                    Ty=numerictype(Ty_name);
                    To=numerictype(To_name);
                    if~isfloat(Tx)&&~isfloat(Ty)&&~isfloat(To)&&...
                        Tx.WordLength<=32&&Ty.WordLength<=32&&To.WordLength<=32&&...
                        strcmp(get_param(blk,'ExtrapMethod'),'Clip')&&...
                        strcmp(get_param(blk,'InterpMethod'),'Linear point-slope')
                        this_lut.types=[Tx,Ty,To];
                        approx_luts=[approx_luts,this_lut];%#ok<AGROW>
                    end
                end
            end
        end
    end
end


