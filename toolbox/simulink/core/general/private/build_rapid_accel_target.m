function[varargout]=build_rapid_accel_target(iMdl,varargin)



























    fh=@loc_build_rapid_accel_target;
    [varargout{1:nargout}]=cpp_feval_wrapper(fh,iMdl,varargin{:});
end

function[varargout]=loc_build_rapid_accel_target(iMdl,varargin)

    if ishandle(iMdl)
        iMdl=get_param(iMdl,'Name');
    end

    if isstring(iMdl)
        iMdl=convertStringsToChars(iMdl);
    end






    if strcmp(get_param(iMdl,'RapidAcceleratorSimStatus'),'updating')||...
        strcmp(get_param(iMdl,'RapidAcceleratorSimStatus'),'building')
        ME=MException(message('Simulink:tools:rapidAccelSecondSim',iMdl));
        ME.throw();
    end

    oldMode=get_param(iMdl,'SimulationMode');
    set_param(iMdl,'SimulationMode','Rapid');
    model_cleanup=onCleanup(@()set_param(iMdl,'SimulationMode',oldMode));










    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'RapidAccelBuild',true);

    varargout{nargout}=[];


    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'RapidAccelUnpack',true);

    if~Simulink.isRaccelDeploymentBuild
        slxcCleanup=onCleanup(@()builtin('_removeAllSLCacheModelInfo'));
        builtin('_unpackSLCacheRapidAccel',iMdl);
    end

    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'RapidAccelUnpack',false);

    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'SetUpForBuild',true);


    Simulink.filegen.internal.FolderConfiguration(iMdl,bdIsLoaded(iMdl));

    xtester_emulate_ctrl_c('rapid_accel_1');

    cpp_feval_wrapper('rapid_accel_target_utils','init_up_to_date_check_on',iMdl,varargin{:});




    buildData=get_param(iMdl,'RapidAcceleratorBuildData');
    exeName=rapid_accel_target_utils('get_exe_name',buildData.buildDir,...
    buildData.mdl);
    storedChecksum=[];
    if exist(exeName,'file')

        storedChecksum=loc_get_checksum(iMdl,buildData.buildDir);

        set_param(iMdl,...
        'StatusString',...
        DAStudio.message('Simulink:tools:rapidAccelCheckingIfUpToDate'));
    end


    if(buildData.opts.debug)
        priorUseTrueIdentifier=...
        get_param(0,'AcceleratorUseTrueIdentifier');
        set_param(0,'AcceleratorUseTrueIdentifier','on');
    end


    if(~buildData.logging.SaveState&&~buildData.logging.SaveFinalState)
        w=warning('off','Simulink:Logging:CannotLogStatesAsMatrix');
        w1=warning('off','Simulink:Logging:CannotLogStatesAsMatrixMenu');
    end

    xtester_emulate_ctrl_c('rapid_accel_2');


    set_param(buildData.mdl,'RapidAcceleratorSimStatus',...
    'building');

    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'SetUpForBuild',false);



    tfl=get_param(iMdl,'SimTargetFcnLibHandle');
    set_param(iMdl,'TargetFcnLibHandle',tfl);
    tfl.doPreRTWBuildProcessing;


    theError='';






    if(~isempty(buildData.compInfo))
        lDefaultCompInfo=buildData.compInfo;
    else
        lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
    end

    try







        cmdlSimInpInfoPtr=0;
        if(nargin>=9)


            cmdlSimInpInfoPtr=varargin{9};
        end

        result=slbuild_private(iMdl,'StandaloneCoderTarget',...
        'StoredChecksum',storedChecksum,...
        'OkayToPushNags',buildData.okayToPushNags,...
        'SlbDefaultCompInfo',lDefaultCompInfo,...
        'CmdlSimInpInfo',cmdlSimInpInfoPtr);
        out=result.buildResult;

    catch e
        theError=e;
    end

    xtester_emulate_ctrl_c('rapid_accel_3');

    if(Simulink.isRaccelDeploymentBuild&&buildData.opts.debug>0)




        rapid_accel_target_utils('raccel_debug_rebuild',buildData);
    end


    set_param(iMdl,'RapidAcceleratorSimStatus','updating');





    buildData=get_param(iMdl,'RapidAcceleratorBuildData');


    if(~buildData.logging.SaveState&&~buildData.logging.SaveFinalState)
        warning(w.state,'Simulink:Logging:CannotLogStatesAsMatrix');
        warning(w1.state,'Simulink:Logging:CannotLogStatesAsMatrixMenu');
    end


    if(buildData.opts.debug)
        set_param(0,'AcceleratorUseTrueIdentifier',priorUseTrueIdentifier);
    end

    if isempty(theError)
        if~isfile(exeName)
            DAStudio.error('Simulink:tools:rapidAccelBuildFailed',iMdl);
        end

        if buildData.logging.SaveFinalState
            if isequal(get_param(iMdl,'SaveFormat'),'Dataset')...
                &&(slfeature('EnableRaccelDatasetAsInitialState')~=0)
                buildData=dataset_initial_state_utils('add_template_dataset',buildData);
            end
        end



        buildData=rapid_accel_target_utils('add_to_from_file_blocks',buildData,...
        iMdl);



        buildData=rapid_accel_target_utils('add_instrumented_signals',buildData,...
        iMdl);

        if~isfield(out,'codeWasUpToDate')
            DAStudio.error('Simulink:tools:rapidAccelBuildFailed',iMdl);
        end
        if(~out.codeWasUpToDate)
            create_checksum_file(...
            out.runTimeParameters.modelChecksum,iMdl,buildData.buildDir);
        end


        if~out.codeWasUpToDate
            buildData.MaxStep=get_param(iMdl,'MaxStep');
            buildData.MinStep=get_param(iMdl,'MinStep');
            buildData.RelTol=get_param(iMdl,'RelTol');
            buildData.AbsTol=get_param(iMdl,'AbsTol');
            buildData.InitialStep=get_param(iMdl,'InitialStep');
            buildData.MaxConsecutiveMinStep=get_param(iMdl,'MaxConsecutiveMinStep');
            buildData.MaxConsecutiveZCs=get_param(iMdl,'MaxConsecutiveZCs');
            buildData.ConsecutiveZCsStepRelTol=get_param(iMdl,'ConsecutiveZCsStepRelTol');
            buildData.ZCThreshold=get_param(iMdl,'ZCThreshold');
        end

        xtester_emulate_ctrl_c('rapid_accel_4');


        if~isfield(out,'runTimeParameters')
            DAStudio.error('Simulink:tools:rapidAccelBuildFailed',iMdl);
        end
        runTimeParameters=out.runTimeParameters;

        buildData=rapid_accel_target_utils('obtain_to_from_file_filenames',buildData,iMdl);


        if get_param(iMdl,'UseSLExecSimBridge')>0
            buildData.serializedModelInfo=...
            get_param(iMdl,'RaccelSerializedModelInfo');
        end


        buildData.isExportFunction=strcmpi(get_param(iMdl,'IsExportFunctionModel'),'on');



        buildData.DecoupledContinuousIntegration=strcmpi(get_param(iMdl,'CompiledDecoupledContinuousIntegration'),'on');
        buildData.OptimalSolverResetCausedByZc=strcmpi(get_param(iMdl,'OptimalSolverResetCausedByZc'),'on');



        buildData.compiledSolverName=get_param(iMdl,'CompiledSolverName');

        buildData.solverStatusFlags=get_param(iMdl,'SolverStatusFlags');

        buildData.compiledStepSize=get_param(iMdl,'CompiledStepSize');

        buildData.hasSrcBlksForAutoHmaxCalc=...
        get_param(iMdl,'HasSrcBlksForAutoHmaxCalc');



        buildData=rapid_accel_target_utils('add_dataflow_configuration_info',buildData,iMdl);



        buildData=rapid_accel_target_utils('add_SimHardwareAcceleration_info',buildData,iMdl);

        rapid_accel_target_utils('save_static_data',buildData);

        rapid_accel_target_utils('create_slvr_file',buildData);
        set_param(iMdl,'Dirty',buildData.bdParams{end}{3});

        rapid_accel_target_utils('setup_ext_inputs',buildData);

        if~out.codeWasUpToDate
            rapid_accel_target_utils(...
            'create_build_ext_input_file',...
buildData...
            );

            rapid_accel_target_utils(...
            'create_build_initial_state_file',...
            out.initialState,...
            buildData.buildDir...
            );

            if(Simulink.isRaccelDeploymentBuild)
                rapid_accel_target_utils(...
                'create_enum_file',...
                out.aggregateEnumInfo,...
buildData...
                );
            end

            rapid_accel_target_utils(...
            'create_mask_tree_file',...
            iMdl,...
            out.maskTree,...
buildData...
            );
        end




        if isfield(out,'aggregateSFcnInfo')&&...
            (slfeature('RapidAcceleratorSFcnMexFileLoading')>0||...
            slfeature('MdlRefSFcnMexFileLoading')>0)

            loc_create_sfcn_info_file(...
            out.aggregateSFcnInfo,...
            iMdl,...
            buildData.buildDir...
            );

        end

        xtester_emulate_ctrl_c('rapid_accel_5');


        if~out.codeWasUpToDate




            rtpTmp=runTimeParameters;
            rtpTmp=rapid_accel_target_utils('loc_edit_rtp',...
            rtpTmp,iMdl,buildData.buildDir);
            buildPrmFile=rapid_accel_target_utils('get_build_prm_file',...
            buildData.buildDir);


            modelChecksum=rtpTmp.modelChecksum;
            parameters=rtpTmp.parameters;
            globalParameterInfo=rtpTmp.globalParameterInfo;
            collapsedBaseWorkspaceVariables=rtpTmp.collapsedBaseWorkspaceVariables;
            nonTunableVariables=rtpTmp.nonTunableVariables;
            save(buildPrmFile,'-v7','modelChecksum','parameters','globalParameterInfo','collapsedBaseWorkspaceVariables','nonTunableVariables');
        end


        rapid_accel_target_utils('create_prm_file',buildData.buildDir,...
        buildData.tmpVarPrefix,runTimeParameters,...
        iMdl);

        rapid_accel_target_utils('create_siglogselector_file',buildData);

        if Simulink.isRaccelDeploymentBuild
            rapid_accel_target_utils('create_model_workspace_file',iMdl,buildData);
        end

        if nargout>0
            varargout{1}=runTimeParameters;
        end


        PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
        'RapidAccelPack',true);


        if~Simulink.isRaccelDeploymentBuild
            omitExt=Simulink.packagedmodel.getSLXCObjectFileExtension('toolchain',lDefaultCompInfo.ToolchainInfo);
            builtin('_packSLCacheRapidAccel',iMdl,out.codeWasUpToDate,buildData.okayToPushNags,omitExt);
        end

        PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
        'RapidAccelPack',false);

    else
        err_id_default='Simulink:tools:rapidAccelBuildFailed';
        err_id=err_id_default;

        comp=coder.make.internal.getMexCompilerInfo();
        if isempty(comp)||strcmp(comp.compStr,'LCC-x')
            err_id='Simulink:tools:rapidAccelLCCBuildFailed';
        end
        err_to_throw=MException(message(err_id,iMdl));



        if~slfeature('RapidAcceleratorHonorTargetLangSupport')&&...
            isequal(buildData.configSet{1}.get_param('TargetLang'),'C++')
            maybe_CPP_err_ID='Simulink:tools:rapidAccelBuildFailedMaybeCPP';
            err_maybe_CPP=MException(message(maybe_CPP_err_ID,iMdl));
            err_to_throw=err_to_throw.addCause(err_maybe_CPP);
        end
        err_to_throw=err_to_throw.addCause(theError);
        err_to_throw.throw();
    end

    PerfTools.Tracer.logSimulinkData('Performance Advisor Stats',iMdl,'RapidAccelSim',...
    'RapidAccelBuild',false);
    xtester_emulate_ctrl_c('rapid_accel_6');
end


function storedChecksum=loc_get_checksum(mdl,buildDir)





    PerfTools.Tracer.logSimulinkData('Simulink Compile',mdl,...
    'RapidAccelSim','Get Checksum',true);
    mlock;
    persistent curVerStruct;
    if isempty(curVerStruct)
        curVerStruct=ver('simulinkcoder');
        if(isempty(curVerStruct)),curVerStruct=ver('simulink');end
    end
    storedChecksum=[];
    checksumFile=get_checksum_file(mdl,buildDir);
    if exist(checksumFile,'file')
        csInfo=load(checksumFile);
        storedCS=csInfo.raccelChecksum;
        storedVersion=csInfo.raccelVersion;
        if(~isempty(storedCS)&&~isempty(curVerStruct)&&...
            isequal(curVerStruct.Version,storedVersion))

            storedChecksum=uint32(storedCS);
        end
    end
    PerfTools.Tracer.logSimulinkData('Simulink Compile',mdl,...
    'RapidAccelSim','Get Checksum',false);
end


function checksumFile=get_checksum_file(mdl,buildDir)
    checksumFile=[buildDir,filesep,mdl,'_get_checksum.mat'];
end


function create_checksum_file(raccelChecksum,mdl,buildDir)
    checksumFile=get_checksum_file(mdl,buildDir);
    curVerStruct=ver('simulinkcoder');
    if(isempty(curVerStruct)),curVerStruct=ver('simulink');end
    raccelVersion=[];%#ok
    if(~isempty(curVerStruct)),raccelVersion=curVerStruct.Version;end %#ok
    raccelChecksum=uint32(raccelChecksum);%#ok
    save(checksumFile,'raccelChecksum','raccelVersion');
end


function loc_create_sfcn_info_file(sFcnInfo,mdl,buildDir)
    if isempty(sFcnInfo)
        return;
    end

    sFcnInfoFile=[buildDir,filesep,mdl,'_sfcn_info.mat'];
    save(sFcnInfoFile,'sFcnInfo');
end



