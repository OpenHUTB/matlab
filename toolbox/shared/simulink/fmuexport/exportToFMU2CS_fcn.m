function is_exported=exportToFMU2CS_fcn(model,callsite,varargin)






    if slsvTestingHook('FMUExportTestingMode')==2
        modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
        modelSettingBackup.remove(modelSettingBackup.keys);
    end

    try


        pb=Simulink.fmuexport.internal.ProgressBar(model,callsite);
        restoreObj=onCleanup(@()pb.delete);


        is_exported=true;


        model=convertStringsToChars(model);


        assert(strcmp(callsite,'CL')||strcmp(callsite,'UI'));



        modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
        modelSettingBackup([model,'.CallSite'])=callsite;
        modelSettingBackup([model,'.HarnessModelName'])='';
        modelSettingBackup([model,'.ProjectName'])='';
        modelSettingBackup([model,'.ProgressBarHandle'])=pb;


        clearPbHandle=onCleanup(@()deleteFromModelSetting(model,modelSettingBackup,'ProgressBarHandle'));

        if~bdIsLoaded(model)
            load_system(model);
            restoreObj=[onCleanup(@()close_system(model,0)),restoreObj];
        end
        restoreObj=[onCleanup(@()cleanupModelSettings(model)),restoreObj];


        pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusCheckLibrary',model)),5);
        if strcmp(get_param(model,'BlockDiagramType'),'library')
            assert(strcmp(callsite,'CL'),'No entrypoint in library UI');
            ME=MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidLibraryBuild',model));
            throw(ME);
        end


        options=get_options(model,varargin);
        if strcmp(callsite,'UI')

            if strcmp(options.ExportedContent,'project')&&...
                (exist(fullfile(options.SaveDirectory,[options.ProjectName,'.mlproj']))==2)
                throw(MSLException([],...
                message('FMUExport:FMU:ProjectAlreadyExists',[options.ProjectName,'.mlproj'])));
            end

            checkExistingFMUFile(model,options.SaveDirectory);
        end



        if strcmp(options.Generate32BitDLL,'on')
            if strcmp(options.ExportedContent,'project')
                msg=DAStudio.message('FMUExport:FMU:FMU2ExpCS32BitCannotGenerateProject');
                coder.internal.fmuexport.reportMsg(msg,'Info',model);
                options.ExportedContent='off';
            end
            if strcmp(options.CreateModelAfterGeneratingFMU,'on')
                msg=DAStudio.message('FMUExport:FMU:FMU2ExpCS32BitCannotGenerateModel');
                coder.internal.fmuexport.reportMsg(msg,'Info',model);
                options.CreateModelAfterGeneratingFMU='off';
            end
        end


        if slfeature('FMUNativeSimulinkBehavior')>0
            add_protected_model(model,options);
        else


            options.AddNativeSimulinkBehavior='off';
        end



        pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusCacheConfigSet',model)),25);
        activeCS=getActiveConfigSet(model);
        restoreObj=[backup_config_set(model,activeCS),restoreObj];


        if(~strcmp(get_param(model,'TargetLang'),'C'))
            ME=MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidTargetLang'));
            throw(ME);
        end



        pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusModifyModelSettings',model)),28);
        param='GenCodeOnly';
        newValue='off';
        if(~strcmp(get_param(model,param),newValue))
            paramEnabledOC=[];
            configLockOC=[];
            try


                configSet=getActiveConfigSet(model);
                if~configSet.getPropEnabled(param)
                    configSet.setPropEnabled(param,'on');
                    paramEnabledOC=onCleanup(@()configSet.setPropEnabled(param,'off'));
                end
                if configSet.isLockedForSim
                    configSet.unlock;
                    configLockOC=onCleanup(@()configSet.lock);
                end
            catch
            end

            msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterTurnedOff',param);
            coder.internal.fmuexport.reportMsg(msg,'Info',model);
            pb.setProgressBarInfo(msg,30);
            set_param(model,param,newValue);
            try
                if~isempty(paramEnabledOC)
                    paramEnabledOC.delete;
                end
                if~isempty(configLockOC)
                    configLockOC.delete;
                end
            catch
            end
        end

        dirty_flag=get_param(model,'Dirty');
        restoreObj=[onCleanup(@()set_param(model,'Dirty',dirty_flag)),restoreObj];


        orig_tlc=do_auto_settings(model);
        restoreObj=[onCleanup(@()restore_from_auto_settings(model,orig_tlc)),restoreObj];


        restoreObj=[do_verbose_settings(model),restoreObj];




        restoreObj=[do_modelref_settings(model),restoreObj];




        restoreObj=[set_hardware_settings(model),restoreObj];





        modelSettingBackup([model,'.Package'])=options.Package;

        clearPackage=onCleanup(@()deleteFromModelSetting(model,modelSettingBackup,'Package'));

        if slfeature('FMUExportParameterConfiguration')>0

            restoreObj=[setDefaultParameterBehavior(model),restoreObj];

            restoreObj=[setParameterConfiguration(model,options),restoreObj];
        end

        if slfeature('FMUExportInternalVarConfiguration')>0

            restoreObj=[setInternalVarConfiguration(model,options),restoreObj];
        end


        modelSettingBackup([model,'.canBeInstantiatedOnlyOncePerProcessOverride'])=options.canBeInstantiatedOnlyOncePerProcessOverride;
        modelSettingBackup([model,'.initialUnknownDependenciesOverride'])=options.initialUnknownDependenciesOverride;


        set_options(model,options);


        registerTopModelForFMUBuild(model);




        if(strcmp(options.Generate32BitDLL,'on'))
            try
                pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusSetModelToExport32BitBinary',model)),35);

                if~ispc
                    error(message('FMUExport:FMU:FMU2ExpCS32BitUnsupported'));
                else
                    currentToolchain=get_param(model,'Toolchain');
                    if strcmp(currentToolchain,'Automatically locate an installed toolchain')
                        currentToolchain=coder.make.getDefaultToolchain;
                    end
                    if isempty(regexp(currentToolchain,'Microsoft Visual C\+\+ 20\d\d','once'))

                        toolchains=coder.make.getToolchains;
                        MSVC_Versions=regexp(toolchains,'^Microsoft Visual C\+\+ 20\d\d');
                        MSVC_Versions=cellfun(@(a)~isempty(a),MSVC_Versions);
                        if~any(MSVC_Versions)
                            error(message('FMUExport:FMU:FMU2ExpCS32BitUnsupported'));
                        else
                            toolchains=toolchains(MSVC_Versions);
                            currentToolchain=toolchains{1};
                        end
                    end
                end
                versionNumber=extractBetween(currentToolchain,'v',' ');


                [path,~,~]=fileparts(mfilename('fullpath'));


                restoreObj=[get_x86_toolchain(versionNumber{1},options,model),restoreObj];


                restoreObj=[reg_x86_toolchain(path,options),restoreObj];


                restoreObj=[set_x86_codegen_settings(model),restoreObj];

            catch ME
                rethrow(ME);
            end
        end




        restoreObj=[skipCheckSumCheckingForModelRef(model),restoreObj];
        restoreObj=[ensureSTFConsistentyForModelRef(model),restoreObj];



        pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusInitiateBinaryGeneration',model)),40);
        compileTimeCleanupObj=Simulink.fmuexport.internal.CompileTimeInfoUtil(model);
        restoreObj=[onCleanup(@()compileTimeCleanupObj.delete),restoreObj];

        try

            slbuild(model);

            pb.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusPerformCleanup')),95);

            clean_up_modelref_slprj();


            clean_up_rtw_folder(model);
        catch ex
            rethrow(ex);
        end


        fmu_name=[model,'.fmu'];
        assert(exist(fullfile(options.SaveDirectory,fmu_name),'file')==2);


        msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSSuccess',...
        fullfile(options.SaveDirectory,fmu_name));
        coder.internal.fmuexport.reportMsg(msg,'Info',model);
        pb.setProgressBarInfo(msg,98);


        load_icon(model);

    catch ME
        clear restoreObj



        if slsvTestingHook('FMUExportTestingMode')==2
            evalin('base','clear ModelInfoUtilInitialized');
            modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
            assert(isempty(modelSettingBackup.keys),'entries not removed after error');
        end


        if(isequal(ME.identifier,'RTW:makertw:invalidSolverOption'))
            ME=MSLException([],ME.identifier,ME.message);
            ME=addCause(ME,MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidSolverType')));
            throw(ME);
        else
            rethrow(ME);
        end
    end

    clear restoreObj



    if slsvTestingHook('FMUExportTestingMode')==2
        evalin('base','clear ModelInfoUtilInitialized');
        modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
        assert(isempty(modelSettingBackup.keys),'entries not removed after error');
    end

end



function cleanupModelSettings(modelName)
    try

        modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
        idxToRemove=startsWith(modelSettingBackup.keys,[modelName,'.']);
        keys=modelSettingBackup.keys;
        modelSettingBackup.remove(keys(idxToRemove));
    catch
    end
end


function add_protected_model(model,options)



    is_beta=~isempty(ver(fullfile('toolbox','shared','simulink','fmuexport')));
    if(is_beta);return;end
    if(~strcmpi(options.AddNativeSimulinkBehavior,'on'));return;end
    slxpName=[model,'.slxp'];
    slxpRename=[model,'_tempname.slxp'];


    modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
    pbHandle=modelSettingBackup([model,'.ProgressBarHandle']);
    pbHandle.setProgressBarInfo(getString(message('FMUExport:FMU:FMU2ExpCSStatusAddNativeSimulinkBehavior',model)),10);


    [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSNativeModelWithBusElement');
    busElementPorts=find_system(model,'regexp','on','SearchDepth','1','BlockType','Inport|Outport','IsBusElementPort','on');
    assert(isempty(busElementPorts),id,msg);


    varObj=Simulink.findVars(model,'FindUsedVars','on','IncludeEnumTypes','on');
    [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSExternalDataDependency');
    assert(all(arrayfun(@(x)~ismember(x.SourceType,{'data dictionary','MATLAB file','dynamic class'}),varObj)),id,msg);


    outputPort=find_system(model,'SearchDepth','1','BlockType','Outport');
    busOutputPort=outputPort(cellfun(@(x)startsWith(get_param(x,'OutDataTypeStr'),'Bus:'),outputPort));
    virtualBusOutPort=busOutputPort(cellfun(@(x)strcmpi(get_param(x,'BusOutputAsStruct'),'off'),busOutputPort));
    if~isempty(virtualBusOutPort)
        cellfun(@(x)set_param(x,'BusOutputAsStruct','on'),virtualBusOutPort);

        Cl1=onCleanup(@()cellfun(@(x)set_param(x,'BusOutputAsStruct','off'),virtualBusOutPort));


        modelFilePath=get_param(model,'FileName');
        [~,fAttrib]=fileattrib(modelFilePath);
        isSuccess=fileattrib(modelFilePath,'+w');
        [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSReadOnlyModelWithVirtualBusOutport');
        assert(isSuccess,id,msg)


        if fAttrib.UserWrite,writeOp='+w';else,writeOp='-w';end
        Cl1=onCleanup(@(x)fileattrib(modelFilePath,writeOp));
        save_system(model);
    end



    warningId=warning('off','Simulink:protectedModel:ProtectedModelCallbackLostWarning');
    Cl2=onCleanup(@()warning(warningId));
    Simulink.ModelReference.protect(model,'Report',true,'Webview',false);
    [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSNativeSimulinkArtifactError');
    assert(exist(fullfile(pwd,slxpName),'file')==4,id,msg);

    if~isempty(virtualBusOutPort)
        clear Cl1
        save_system(model);
    end




    [is_moved,~,~]=movefile(slxpName,slxpRename,'f');
    [msg,id]=DAStudio.message('FMUExport:FMU:FMU2ExpCSNativeSimulinkArtifactError');
    assert(is_moved,id,msg);
end


function load_icon(model)
    if(bdIsLoaded([model,'_fmu'])&&strcmp(get_param(model,'CreateModelAfterGeneratingFMU'),'on'))
        import_block=[model,'_fmu/Generated FMU Block'];
        set_param(import_block,'FMUParamMapping','flat');
        set_param(import_block,'FMUParamMapping','inherit');
    end
end

function orig_setting=do_auto_settings(model)
    orig_setting=get_param(model,'SystemTargetFile');
    if(~strcmp(orig_setting,'fmu2cs.tlc'))
        set_param(model,'SystemTargetFile','fmu2cs.tlc');
        msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterResetSystemTarget',model);
        coder.internal.fmuexport.reportMsg(msg,'Info',model);
    end
end

function restore_from_auto_settings(model,origSetting)
    try
        set_param(model,'SystemTargetFile',origSetting);
    catch

        set_param(model,'SystemTargetFile','grt.tlc');
    end
end

function origConfigSetOCObj=backup_config_set(model,activeCS)
    tempCS=activeCS;
    while isa(tempCS,'Simulink.ConfigSetRef')
        tempCS=tempCS.getRefConfigSet();
    end
    tempCS=tempCS.copy;
    slInternal('substituteTmpConfigSetForBuild',get_param(model,'handle'),...
    activeCS,tempCS);
    origConfigSetOCObj=onCleanup(@()slInternal('restoreOrigConfigSetForBuild',...
    get_param(model,'handle'),activeCS,tempCS));
end

function origVerboseOCObj=do_verbose_settings(model)
    orig_setting=get_param(model,'RTWVerbose');
    if~strcmp(orig_setting,'off')
        set_param(model,'RTWVerbose','off');
    end
    origVerboseOCObj=onCleanup(@()restore_verbose_settings(model,orig_setting));
end

function restore_verbose_settings(model,origSetting)
    try
        set_param(model,'RTWVerbose',origSetting);
    catch
    end
end

function origModelRefOCObj=do_modelref_settings(model)
    orig_setting=get_param(model,'EnableParallelModelReferenceBuilds');
    if~strcmp(orig_setting,'off')
        set_param(model,'EnableParallelModelReferenceBuilds','off');
    end
    origModelRefOCObj=onCleanup(@()restore_modelref_settings(model,orig_setting));
end

function restore_modelref_settings(model,origSetting)
    try
        set_param(model,'EnableParallelModelReferenceBuilds',origSetting);
    catch
    end
end

function checksumOCObjs=skipCheckSumCheckingForModelRef(model)








    [~,~,aGraph]=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    analyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    analysis=analyzer.analyze(aGraph,'All','IncludeTopModel',false,'ResultView','File');
    refModels=analysis.RefModel(2:end);
    isLoaded=num2cell(analysis.IsLoaded(2:end));

    checksumOCObjs=cellfun(@(x,y)loadRefModelAndUpdateSettings(x,y),refModels,isLoaded)';
end

function restoreRefModelOCObj=loadRefModelAndUpdateSettings(refModel,isLoaded)
    loadModelOCObj=onCleanup(@()fprintf(''));
    if~isLoaded
        load_system(refModel);
        loadModelOCObj=onCleanup(@()close_system(refModel,0));
    end

    checkSetting=get_param(refModel,'ModelReferenceMultiInstanceNormalModeStructChecksumCheck');

    dirty=get_param(refModel,'Dirty');

    restoreConfigSetOCObj=backup_config_set(refModel,getActiveConfigSet(refModel));
    restoreRefModelOCObj=onCleanup(@()restoreRefModelAndUpdateSettings(refModel,checkSetting,dirty,restoreConfigSetOCObj,loadModelOCObj));
    set_param(refModel,'ModelReferenceMultiInstanceNormalModeStructChecksumCheck','none');
    set_param(refModel,'Dirty','off');
end

function restoreRefModelAndUpdateSettings(refModel,origCheckSetting,origIsDirty,oc1,oc2)
    set_param(refModel,'ModelReferenceMultiInstanceNormalModeStructChecksumCheck',origCheckSetting);
    set_param(refModel,'Dirty',origIsDirty);
    oc1.delete;
    oc2.delete;
end

function cghwOCObjs=ensureSTFConsistentyForModelRef(model)



    [~,~,aGraph]=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    analyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    analysis=analyzer.analyze(aGraph,'All','IncludeTopModel',false,'ResultView','File');
    refModels=analysis.RefModel(2:end);

    cghwOCObjs=cellfun(@(x)updateModelRefCGHWSettings(x,model),refModels)';
end

function restoreRefModelOCObj=updateModelRefCGHWSettings(refModel,topModel)
    restoreRefModelOCObj=coder.internal.fmuexport.ensureSTFConsistency(refModel,topModel);
end

function origHWImplOCObj=set_hardware_settings(model)


    configSet=getActiveConfigSet(model);
    hardware=configSet.getComponent('Hardware Implementation');
    origHardware=copy(hardware);
    slprivate('setHardwareDevice',hardware,'Target','MATLAB Host');
    msg=DAStudio.message('FMUExport:FMU:FMU2ExpCSParameterResetHWDevice',model);
    coder.internal.fmuexport.reportMsg(msg,'Info',model);
    origHWImplOCObj=onCleanup(@()restore_hardware_settings(model,origHardware));
end

function restore_hardware_settings(model,origSetting)
    configSet=getActiveConfigSet(model);
    configSet.attachComponent(origSetting);
end

function origCodegenImplOCObj=set_x86_codegen_settings(model)

    configSet=getActiveConfigSet(model);
    hardware=configSet.getComponent('Hardware Implementation');
    origHardware=copy(hardware);
    codegen=configSet.getComponent('Code Generation');
    origCodegen=copy(codegen);

    set_param(model,'ProdHWDeviceType','Intel->x86-32 (Windows32)');
    set_param(model,'Toolchain','MSVC 32 Bit Toolchain for FMU Export');

    origCodegenImplOCObj=onCleanup(@()restore_codegen_settings(model,origHardware,origCodegen));
end

function restore_codegen_settings(model,origHWSetting,origCodegenSetting)


    configSet=getActiveConfigSet(model);
    configSet.attachComponent(origHWSetting);
    configSet.attachComponent(origCodegenSetting);
end

function deleteToolchainOCObj=get_x86_toolchain(versionNumber,options,model)
    msg=DAStudio.message('FMUExport:FMU:FMU2ExpCS32BitToolchainGenerating');
    coder.internal.fmuexport.reportMsg(msg,'Info',model);
    tc=fmu_reg_x86_toolchain(versionNumber);
    save(fullfile(options.SaveDirectory,'msvc_32bit_fmuexport'),'tc');
    msg=DAStudio.message('FMUExport:FMU:FMU2ExpCS32BitToolchainComplete');
    coder.internal.fmuexport.reportMsg(msg,'Info',model);

    deleteToolchainOCObj=onCleanup(@()delete_x86_toolchain(options,'msvc_32bit_fmuexport.mat'));
end

function delete_x86_toolchain(options,filename)
    delete(fullfile(options.SaveDirectory,filename));
end

function unregToolchainOCObj=reg_x86_toolchain(path,options)
    copyfile(fullfile(path,'x86_fmu_rtw_target_info','x86FMURtwTargetInfo.p'),...
    fullfile(options.SaveDirectory,'rtwTargetInfo.p'),'f');
    addpath(options.SaveDirectory);
    RTW.TargetRegistry.getInstance('reset');

    unregToolchainOCObj=onCleanup(@()unreg_x86_toolchain(options,'rtwTargetInfo.p'));
end

function unreg_x86_toolchain(options,filename)
    delete(fullfile(options.SaveDirectory,filename));
    rmpath(options.SaveDirectory);
    RTW.TargetRegistry.getInstance('reset');
end

function ret_val=is_param(model,param)
    obj_params=get_param(model,'ObjectParameters');
    ret_val=isfield(obj_params,param);
end

function options=get_options(model,opt_args)

    options.CreateModelAfterGeneratingFMU='off';
    options.SaveSourceCodeToFMU='off';
    options.SaveDirectory=pwd;
    options.AddIcon='snapshot';
    options.ExportedContent='off';
    options.Generate32BitDLL='off';
    options.ProjectName=[model,'_fmu'];

    options.ExportedParameters={};
    options.ExportedParameterNames={};

    options.ExportedInternals={};
    options.ExportedInternalNames={};

    options.Package=[];

    options.AddNativeSimulinkBehavior='off';
    options.canBeInstantiatedOnlyOncePerProcessOverride='off';
    options.initialUnknownDependenciesOverride='off';






    if~isempty(opt_args)
        assert(iscell(opt_args));


        if numel(opt_args)==1&&isstruct(opt_args{1})&&numel(opt_args{1})==1
            for i=fieldnames(opt_args{1})'
                options.(i{1})=opt_args{1}.(i{1});
            end

        elseif mod(numel(opt_args),2)==0
            par_arr=opt_args(1:2:end);
            val_arr=opt_args(2:2:end);
            for i=1:numel(par_arr)
                par=par_arr{i};
                val=val_arr{i};
                if~ischar(par)&&~isstring(par)
                    throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptions')));
                elseif strcmp(par,'Package')


                    options.Package=convertPackageToStruct(val);
                else
                    options.(par)=val;
                end
            end
        else
            throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptions')));
        end
    end


    verify_options(options,model);



end

function opt_list=validate_option_value(options,option_name,option_set,opt_list)
    assert(isfield(options,option_name),'default option missing this field');
    val=options.(option_name);
    if~ismember(val,option_set)
        option_set_str=['''',strjoin(option_set,''', '''),''''];
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValue',option_name,option_set_str)));
    end
    opt_list=setdiff(opt_list,option_name);
end

function verify_options(options,model)
    assert(isstruct(options));
    opt_list=fieldnames(options);

    opt_list=validate_option_value(options,'CreateModelAfterGeneratingFMU',{'on','off'},opt_list);
    opt_list=validate_option_value(options,'SaveSourceCodeToFMU',{'on','off'},opt_list);
    opt_list=validate_option_value(options,'ExportedContent',{'project','off'},opt_list);

    assert(isfield(options,'SaveDirectory'));
    val=options.SaveDirectory;
    if exist(val,'dir')~=7
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSNonexistingDirectory',val)));
    end
    opt_list=setdiff(opt_list,'SaveDirectory');

    assert(isfield(options,'AddIcon'));
    val=options.AddIcon;
    if~(ismember(val,{'off','snapshot','sl_signature'})||exist(val,'file')==2)
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','AddIcon')));
    end
    opt_list=setdiff(opt_list,'AddIcon');

    opt_list=validate_option_value(options,'Generate32BitDLL',{'on','off'},opt_list);

    assert(isfield(options,'ProjectName'));
    val=options.ProjectName;
    if strcmpi(options.ExportedContent,'project')&&isempty(val)
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','ProjectName')));
    end
    opt_list=setdiff(opt_list,'ProjectName');

    assert(isfield(options,'ExportedParameters'));
    val=options.ExportedParameters;
    if~iscellstr(val)%#ok<ISCLSTR> 
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','ExportedParameters')));
    end
    opt_list=setdiff(opt_list,'ExportedParameters');

    assert(isfield(options,'ExportedParameterNames'));
    val=options.ExportedParameterNames;
    if~iscellstr(val)%#ok<ISCLSTR> 
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','ExportedParameterNames')));
    end
    hasDuplicates=numel(unique(val))<numel(val);
    if hasDuplicates
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSDuplicateVarNotAllowed','ExportedParameterNames')));
    end
    opt_list=setdiff(opt_list,'ExportedParameterNames');

    assert(isfield(options,'ExportedInternals'));
    val=options.ExportedInternals;
    if~iscellstr(val)
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','ExportedInternals')));
    end
    opt_list=setdiff(opt_list,'ExportedInternals');

    assert(isfield(options,'ExportedInternalNames'));
    val=options.ExportedInternalNames;
    if~iscellstr(val)
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','ExportedInternalNames')));
    end
    hasDuplicates=numel(unique(val))<numel(val);
    if hasDuplicates
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSDuplicateVarNotAllowed','ExportedInternalNames')));
    end
    opt_list=setdiff(opt_list,'ExportedInternalNames');

    assert(isfield(options,'Package'));


    val=options.Package;
    if~isempty(val)&&~isstruct(val)
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','Package')));
    end
    validateUserSpecifiedFiles(val,...
    model,...
    options.Generate32BitDLL,...
    options.SaveSourceCodeToFMU);
    opt_list=setdiff(opt_list,'Package');

    opt_list=validate_option_value(options,'AddNativeSimulinkBehavior',{'on','off'},opt_list);
    opt_list=validate_option_value(options,'canBeInstantiatedOnlyOncePerProcessOverride',{'on','off'},opt_list);
    opt_list=validate_option_value(options,'initialUnknownDependenciesOverride',{'on','off'},opt_list);


    if~isempty(opt_list)
        option_str=['''',strjoin(opt_list,''', '''),''''];
        msg=message('FMUExport:FMU:FMU2ExpCSIgnoredOptionsField',option_str);
        coder.internal.fmuexport.reportMsg(msg,'Warning',model);
    end
end

function set_options(model,options)
    set_param(model,'CreateModelAfterGeneratingFMU',options.CreateModelAfterGeneratingFMU);
    set_param(model,'ProjectName',options.ProjectName);
    set_param(model,'ExportedContent',options.ExportedContent);
    set_param(model,'SaveSourceCodeToFMU',options.SaveSourceCodeToFMU);
    set_param(model,'SaveDirectory',options.SaveDirectory);
    set_param(model,'AddIcon',options.AddIcon);
    set_param(model,'AddNativeSimulinkBehavior',options.AddNativeSimulinkBehavior);
end

function registerTopModelForFMUBuild(model)



    try
        modelSettingBackup=coder.internal.fmuexport.getSetFMUSetting;
        modelSettingBackup([model,'.CalledFromExportedToFMU2CS'])=1;
    catch
    end
end

function clean_up_modelref_slprj()

    if exist(fullfile(pwd,'slprj','fmu2cs'),'dir')==7
        recycle_origval=recycle('off');
        recycle_cleanup=onCleanup(@()recycle(recycle_origval));
        rmdir(fullfile(pwd,'slprj','fmu2cs'),'s');
    end
end

function clean_up_rtw_folder(model)

    if exist(fullfile(pwd,[model,'_fmu2cs_rtw']),'dir')==7
        recycle_origval=recycle('off');
        recycle_cleanup=onCleanup(@()recycle(recycle_origval));
        rmdir(fullfile(pwd,[model,'_fmu2cs_rtw']),'s');
    end
end

function checkExistingFMUFile(model,filePath)


    fileName=[model,'.fmu'];
    fmuFilePath=fullfile(filePath,fileName);

    if(exist(fmuFilePath,'file')==2)
        result=questdlg(DAStudio.message(...
        'FMUExport:FMU:FMUOverwriteDlgDescription',fileName),...
        DAStudio.message('Simulink:editor:DialogMessage'),...
        DAStudio.message('Simulink:editor:DialogYes'),...
        DAStudio.message('Simulink:editor:DialogNo'),...
        DAStudio.message('Simulink:editor:DialogYes'));

        if strcmp(result,DAStudio.message('Simulink:editor:DialogYes'))
            delete(fmuFilePath);
            return;
        else
            throw(MSLException([],message('FMUExport:FMU:FMUAlreadyExists',fileName)));
        end
    end
end

function origDefaultParameterBehaviorOCObj=setDefaultParameterBehavior(model)
    origDefaultParameterBehavior=get_param(model,'DefaultParameterBehavior');
    if~strcmp(origDefaultParameterBehavior,'Tunable')
        set_param(model,'DefaultParameterBehavior','Tunable');
    end
    origDefaultParameterBehaviorOCObj=onCleanup(@()set_param(model,'DefaultParameterBehavior',origDefaultParameterBehavior));
end

function origParameterConfigurationOCObj=setParameterConfiguration(model,options)








    paramListSource=FMU2ExpCSDialog.getParamListSource(model);
    if isempty(options.ExportedParameters)

        for idx=1:length(paramListSource.valueStructure)
            if paramListSource.valueStructure(idx).IsRoot
                options.ExportedParameters=[options.ExportedParameters,paramListSource.valueStructure(idx).Name];
            end
        end
    elseif strcmp(options.ExportedParameters{1},'')

        for idx=1:length(paramListSource.valueStructure)
            if paramListSource.valueStructure(idx).IsRoot
                paramListSource.valueStructure(idx).exported='off';
            end
        end
    else

        for idx=1:length(paramListSource.valueStructure)
            if paramListSource.valueStructure(idx).IsRoot
                if isempty(intersect(options.ExportedParameters,paramListSource.valueStructure(idx).Name))
                    paramListSource.valueStructure(idx).exported='off';
                else
                    paramListSource.valueStructure(idx).exported='on';
                end
            end
        end
    end
    if isempty(options.ExportedParameterNames)

        options.ExportedParameterNames=options.ExportedParameters;
    else
        assert(length(options.ExportedParameterNames)==length(options.ExportedParameters),'ExportedName should match with ExportedParameters.');

        [~,ia,ib]=intersect(options.ExportedParameters,{paramListSource.valueStructure.Name});
        for k=1:length(ib)
            paramListSource.valueStructure(ib(k)).exportedName=options.ExportedParameterNames{ia(k)};
        end
    end
    assignin('base','paramListSource',paramListSource);
    origParameterConfigurationOCObj=onCleanup(@()evalin('base','clear paramListSource'));
end

function origInternalVarConfigurationOCObj=setInternalVarConfiguration(model,options)



    ivListSource=FMU2ExpCSDialog.getInternalVarListSource(model);
    if isempty(options.ExportedInternals)||strcmp(options.ExportedInternals{1},'')

        for idx=1:length(ivListSource.valueStructure)
            if ivListSource.valueStructure(idx).IsRoot
                ivListSource.valueStructure(idx).exported='off';
            end
        end
    elseif strcmp(options.ExportedInternals{1},'*')

        options.ExportedInternals={};
        for idx=1:length(ivListSource.valueStructure)
            if ivListSource.valueStructure(idx).IsRoot
                ivListSource.valueStructure(idx).exported='on';
                options.ExportedInternals=[options.ExportedInternals,ivListSource.valueStructure(idx).Name];
            end
        end
    else

        for idx=1:length(ivListSource.valueStructure)
            if ivListSource.valueStructure(idx).IsRoot
                if isempty(intersect(options.ExportedInternals,ivListSource.valueStructure(idx).Name))
                    ivListSource.valueStructure(idx).exported='off';
                else
                    ivListSource.valueStructure(idx).exported='on';
                end
            end
        end
    end
    if isempty(options.ExportedInternalNames)

        options.ExportedInternalNames=options.ExportedInternals;
    else
        assert(length(options.ExportedInternalNames)==length(options.ExportedInternals),'ExportedName should match with ExportedParameters.');

        [~,ia,ib]=intersect(options.ExportedInternals,{ivListSource.valueStructure.Name});
        for k=1:length(ib)
            ivListSource.valueStructure(ib(k)).exportedName=options.ExportedInternalNames{ia(k)};
        end
    end
    assignin('base','ivListSource',ivListSource);
    origInternalVarConfigurationOCObj=onCleanup(@()evalin('base','clear ivListSource'));
end

function packageStruct=convertPackageToStruct(packageInfo)



    if iscell(packageInfo)

        if(mod(length(packageInfo),2)~=0)
            throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','Package')));
        end
    else
        throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','Package')));
    end
    packageStruct=[];
    for count=1:2:length(packageInfo)
        destinationFolder=convertStringsToChars(packageInfo{count});
        sourceFolder=packageInfo{count+1};

        if iscell(sourceFolder)

            sourceFolder=cellfun(@(x)convertStringsToChars(x),sourceFolder,'un',0);
        else
            sourceFolder=convertStringsToChars(sourceFolder);
        end

        if ischar(sourceFolder)
            sourceFolder={sourceFolder};
        end



        if~ischar(destinationFolder)||...
            ~iscell(sourceFolder)||...
            any(cellfun(@(x)~(ischar(x)),sourceFolder))
            throw(MSLException([],message('FMUExport:FMU:FMU2ExpCSInvalidOptionsValueNoCandidate','Package')));
        else
            destinationFolder=...
            internal.packageConfig.utility.updateFileSep(destinationFolder);
        end
        [FilePath,FileName,Extension]=cellfun(...
        @(x)internal.packageConfig.utility.findFileparts(x),sourceFolder,...
        'UniformOutput',false);


        tempResourceStruct=arrayfun(@(x)struct('DestinationFolder',destinationFolder,...
        'SourceFolder',FilePath{x},...
        'FileName',FileName{x},...
        'FileType',Extension{x}),1:length(Extension));
        packageStruct=[packageStruct,tempResourceStruct];
    end
end
function validateUserSpecifiedFiles(packageStruct,...
    modelName,Generate32BitDLL,...
    SaveSourceCodeToFMU)




    InValidStruct=packageStruct(...
    (arrayfun(@(x)internal.packageConfig.utility.invalidSourcePath(x),...
    packageStruct)));


    if~isempty(InValidStruct)
        InValidFilePath=arrayfun(@(x)fullfile(x.SourceFolder,x.FileName),...
        InValidStruct,'un',0);
        throw(MSLException([],...
        message('FMUExport:FMU:FMU2ExpCSPackageInvalidSourcePath',...
        strjoin(unique(InValidFilePath),', '))));
    end


    duplicateDestination=...
    arrayfun(@(x)...
    internal.packageConfig.utility.ifDuplicateEntry(packageStruct,x),...
    packageStruct);
    if(any(duplicateDestination))
        throw(MSLException([],...
        message('FMUExport:FMU:FMU2ExpCSPackageIdenticalDestinationPath')));
    end


    InvalidStruct=...
    packageStruct(arrayfun(@(x)internal.packageConfig.utility.isInValidDestinationPath(x),...
    packageStruct));
    if~isempty(InvalidStruct)
        InValidFilePath=arrayfun(@(x)x.DestinationFolder,...
        InvalidStruct,'UniformOutput',false);
        throw(MSLException([],...
        message('FMUExport:FMU:FMU2ExpCSPackageInvalidDestinationFolder',...
        strjoin(unique(InValidFilePath),', '))));
    end


    Generate32BitDLL=strcmpi(Generate32BitDLL,'on');
    InvalidStruct=packageStruct(arrayfun(@(x)...
    internal.packageConfig.utility.isModelBinaryFile(x,modelName,Generate32BitDLL),...
    packageStruct));
    if~isempty(InvalidStruct)
        throw(MSLException([],...
        message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
        fullfile(InvalidStruct(1).SourceFolder,...
        InvalidStruct(1).FileName),...
        fullfile(InvalidStruct(1).DestinationFolder,...
        InvalidStruct(1).FileName))));
    end



    InvalidStruct=packageStruct(arrayfun(@(x)...
    internal.packageConfig.utility.hasFolderWithModelBinary(x,modelName,Generate32BitDLL)&&...
    strcmp(x.DestinationFolder,strcat('binaries',filesep)),...
    packageStruct));
    if~isempty(InvalidStruct)
        ModelBinaryName=strcat(modelName,internal.packageConfig.utility.getBinaryFileExtension);
        throw(MSLException([],...
        message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
        fullfile(InvalidStruct(1).SourceFolder,...
        InvalidStruct(1).FileName,ModelBinaryName),...
        ModelBinaryName)));
    end



    SaveSourceCodeToFMU=strcmpi(SaveSourceCodeToFMU,'on');
    SourceFileStruct=packageStruct(arrayfun(@(x)...
    SaveSourceCodeToFMU&&internal.packageConfig.utility.isSourceFile(x),...
    packageStruct));
    if~isempty(SourceFileStruct)
        SourceFilePathCell=arrayfun(@(x)fullfile(x.SourceFolder,x.FileName),SourceFileStruct,'un',0);
        SourceFilePathStr=strjoin(SourceFilePathCell,'\n');
        msg=message('FMUExport:FMU:FMU2ExpCSPackageSourcesConflict',SourceFilePathStr);
        coder.internal.fmuexport.reportMsg(msg,'Warning',modelName);
    end
end
function deleteFromModelSetting(modelName,modelSettingBackup,keyName)


    idxToRemove=strcmp(modelSettingBackup.keys,[modelName,'.',keyName]);
    keys=modelSettingBackup.keys;
    modelSettingBackup.remove(keys(idxToRemove));
end
