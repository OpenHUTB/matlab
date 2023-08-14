function dpigenerator_hookpoints(hookPoint,modelName,rtwroot,tmf,buildOpts,buildArgs,buildInfo)%#ok















    mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
    isNotModelRefTarget=strcmp(mdlRefTargetType,'NONE');

    if isNotModelRefTarget


        switch hookPoint
        case 'error'




            disp('.');
            disp(['### Build procedure for model: ''',modelName...
            ,''' aborted due to an error.']);

        case 'entry'




            l_check_for_supported_tunable_prm(modelName,strcmp(get_param(modelName,'DPISystemVerilogTemplate'),'hdlverifier_dpitb_template.vgt'));


            if~isempty(which('_simscape_register_supported_rtw_target','-all'))
                builtin(...
                '_simscape_register_supported_rtw_target',...
                'systemverilog_dpi_ert.tlc');
                builtin(...
                '_simscape_register_supported_rtw_target',...
                'systemverilog_dpi_grt.tlc');
            end




            if(contains(get_param(modelName,'Toolchain'),'Mentor Graphics QuestaSim/Modelsim')||contains(get_param(modelName,'Toolchain'),'Cadence Xcelium'))


                Target_HW_Prop={'TargetBitPerChar',...
                'TargetBitPerShort',...
                'TargetBitPerInt',...
                'TargetBitPerLong',...
                'TargetBitPerLongLong',...
                'TargetWordSize',...
                'TargetBitPerPointer',...
                'TargetBitPerSizeT',...
                'TargetBitPerPtrDiffT'};

                if contains(get_param(modelName,'Toolchain'),'64-bit Linux')&&~isunix

                    Linux_HW_conf={8,...
                    16,...
                    32,...
                    64,...
                    64,...
                    64,...
                    64,...
                    64,...
                    64};

                    cellfun(@(prop,val)l_check_dt_sz(modelName,prop,val),Target_HW_Prop,Linux_HW_conf);
                elseif contains(get_param(modelName,'Toolchain'),'32-bit Linux')
                    Linux_HW_conf={8,...
                    16,...
                    32,...
                    32,...
                    64,...
                    32,...
                    32,...
                    32,...
                    32};


                    cellfun(@(prop,val)l_check_dt_sz(modelName,prop,val),Target_HW_Prop,Linux_HW_conf);
                elseif strcmp(computer,'PCWIN64')&&contains(get_param(modelName,'Toolchain'),'32-bit Windows')

                    Win32_HW_conf={8,...
                    16,...
                    32,...
                    32,...
                    64,...
                    32,...
                    32,...
                    32,...
                    32};

                    cellfun(@(prop,val)l_check_dt_sz(modelName,prop,val),Target_HW_Prop,Win32_HW_conf)
                end
            end

            if strcmpi(get_param(modelName,'DPIComponentTemplateType'),'Combinational')



                warning(message('HDLLink:DPIG:CombTemplateWarning'));
            end
















            if hdlverifierfeature('IS_CODEGEN_FOR_UVM')
                sl_name=hdlverifierfeature('SL_BLOCK_NAME');
                assert(strcmp(sl_name,modelName),message('HDLLink:uvmgenerator:CompNameShadowed',sl_name,modelName));
            end


            disp(['### Starting build procedure for model: ',modelName]);

            assert(builtin('license','checkout','EDA_Simulator_Link')~=0,'HDLLink:license','HDL Verifier license checkout failed. Unable to use DPI Generator.');


            dpigenerator_setvariable;
        case 'before_tlc'




        case 'before_codegen'


        case 'after_codegen'


        case 'after_tlc'





            dpigenerator_disp('Starting SystemVerilog DPI Component Generation');

        case 'before_make'







setBuildVariant...
            (buildInfo.BuildTools,coder.make.enum.BuildVariant.SHARED_LIBRARY_TARGET);





            if isunix&&strcmp(get_param(modelName,'SystemTargetFile'),'systemverilog_dpi_grt.tlc')

                buildInfo.addSysLibs('m');
            end



            if strcmp(get_param(modelName,'SystemTargetFile'),'systemverilog_dpi_grt.tlc')
                buildInfo.addDefines({'-DRT -DUSE_RTMODEL'});
            end

            isCodeGenDone=dpigenerator_getvariable('isCodeGenDone');
            if isCodeGenDone

                l_removeFileFromBuildInfo(buildInfo);
                try

                    moduleName=[modelName,'_dpi'];
                    dpigenerator_setvariable('moduleName',moduleName);




                    CurrDir=pwd;
                    c=onCleanup(@()cd(CurrDir));
                    cd(RTW.getBuildDir(modelName).BuildDirectory)

                    dpig_codeinfo=dpigenerator_getcodeinfo();
                    topLevelHasVerifyCalls=l_IncludeTSVerify(buildInfo);


                    modelRefBuildInfos=RTW.BuildInfo.empty;
                    for i=1:length(buildInfo.ModelRefs)
                        mref=buildInfo.ModelRefs(i);

                        mrefBuildInfo=strrep(mref.Path,'$(START_DIR)',buildInfo.Settings.LocalAnchorDir);
                        mrefBuildInfo=load(fullfile(mrefBuildInfo,'buildInfo.mat'));
                        mrefBuildInfo=mrefBuildInfo.buildInfo;
                        modelRefBuildInfos(end+1)=mrefBuildInfo;%#ok<AGROW>
                    end

                    mdlRefHasVerifyCalls=l_IncludeTSVerify(modelRefBuildInfos);
                    dpig_config=dpigenerator_getconfigset(modelName,topLevelHasVerifyCalls,mdlRefHasVerifyCalls);
                    dpig_assertioninfo=dpig.internal.AssertionManager(modelName,dpig_config);
                    dpig_codeinfo.TSBlkPath2SIDMap=dpig.internal.gettsblkpath2sidmap(modelName,dpig_config);







                    dpigenerator_generateCWrapper(moduleName,...
                    dpig_config,dpig_codeinfo,dpig_assertioninfo,buildInfo);






                    if dpig_config.DPICustomizeSystemVerilogCode

                        addNonBuildFiles(buildInfo,fullfile(pwd,[moduleName,'.sv']));

                        CodeGenObj=dpig.internal.GetSVFcn(dpig_codeinfo,'AssertionInfo',dpig_assertioninfo,'dpig_config',dpig_config);
                        dpigenerator_generateSVFromTemplate(moduleName,...
                        CodeGenObj,which(dpig_config.DPISystemVerilogTemplate),...
                        dpig_codeinfo.ParamStruct.NumPorts);
                    elseif hdlverifierfeature('IS_CODEGEN_FOR_UVM')
                        modulePkgName=[moduleName,dpig.internal.GetSVFcn.getPackageFileSuffix()];
                        CodeGenObj=dpig.internal.GetUVMSVFcn(dpig_codeinfo,'AssertionInfo',dpig_assertioninfo,'dpig_config',dpig_config,'Namespace',modulePkgName);

                        addNonBuildFiles(buildInfo,fullfile(pwd,[modulePkgName,'.sv']));
                        addNonBuildFiles(buildInfo,fullfile(pwd,[moduleName,'.sv']));

                        dpigenerator_generateUVMPackage(modulePkgName,...
                        CodeGenObj,dpig_codeinfo.ParamStruct.NumPorts);
                        dpigenerator_generateSVComponent(moduleName,CodeGenObj);
                        CodeGenObj.AddGeneratedArtifactInfo('DPIPkg',fullfile(pwd,[modulePkgName,'.sv']),...
                        'DPIModule',fullfile(pwd,[moduleName,'.sv']),...
                        'SharedLib',fullfile(pwd,moduleName(1:end-4)));

                        CodeGenObj.AddTimingInfo('SimTime',l_getSimTime(modelName),...
                        'BaseRate',dpig_codeinfo.BaseRate);


                        CodeGenObj.AddCompPortInfo();


                        CodeGenObj.StoreUVMCodeInfo();
                    else
                        if dpig_config.IsInterfaceEnabled
                            CodeGenObj=dpig.internal.GetSVInterfaceFcn(dpig_codeinfo,'AssertionInfo',dpig_assertioninfo,'dpig_config',dpig_config);




                            dpig_codeinfo.InterfaceInfo.IsInterfaceEnabled=true;
                            dpig_codeinfo.InterfaceInfo.InterfaceId=CodeGenObj.getInterfaceId();
                            dpig_codeinfo.InterfaceInfo.InterfaceType=CodeGenObj.getInterfaceType();
                        else
                            CodeGenObj=dpig.internal.GetSVFcn(dpig_codeinfo,'AssertionInfo',dpig_assertioninfo,'dpig_config',dpig_config);
                        end

                        modulePkgName=[moduleName,dpig.internal.GetSVFcn.getPackageFileSuffix()];
                        addNonBuildFiles(buildInfo,fullfile(pwd,[modulePkgName,'.sv']));
                        addNonBuildFiles(buildInfo,fullfile(pwd,[moduleName,'.sv']));

                        dpigenerator_generateSVPackage(modulePkgName,...
                        CodeGenObj,dpig_codeinfo.ParamStruct.NumPorts);

                        dpigenerator_generateSVComponent(moduleName,CodeGenObj);
                    end


                    if(dpig_config.DPIGenerateTestBench)
                        if dpig_config.DPICustomizeSystemVerilogCode
                            dpigenerator_disp('Skipping test bench generation since option DPICustomizeSystemVerilogCode is selected');
                        else
                            tbModuleName=[moduleName,'_tb'];
                            dpigenerator_generateTestBench(moduleName,tbModuleName,dpig_codeinfo,buildInfo,dpig_config);
                        end
                    end


                    moduleName=[modelName,'_dpi'];



                    if ispc&&isempty(strfind(buildInfo.BuildTools.Toolchain,'LCC-win64'))




                        fid=fopen([modelName,'.def'],'w+');
                        fprintf(fid,'%s','EXPORTS');
                        fclose(fid);
                    end

                    if(strcmp(computer,'PCWIN32')||strcmp(computer,'PCWIN64'))&&(~isempty(strfind(buildInfo.BuildTools.Toolchain,'64-bit Linux'))||~isempty(strfind(buildInfo.BuildTools.Toolchain,'32-bit Linux')))

                        Porting=true;
                    else
                        Porting=false;

                    end

                    if~isempty(strfind(buildInfo.BuildTools.Toolchain,'QuestaSim/Modelsim'))
                        buildInfo.updateFilePathsAndExtensions;
                        genVsimScript=dpig.internal.GenQuestaSimScript(modelName,buildInfo,Porting,...
                        get_param(modelName,'BuildConfiguration'),...
                        get_param(modelName,'CustomToolchainOptions'));
                        genVsimScript.doIt;

                        addNonBuildFiles(buildInfo,fullfile(pwd,[modelName,'.do']));


                    elseif~isempty(strfind(buildInfo.BuildTools.Toolchain,'Xcelium (64-bit Linux)'))
                        buildInfo.updateFilePathsAndExtensions;
                        genXcelScript=dpig.internal.GenXceliumScript(modelName,buildInfo,...
                        get_param(modelName,'BuildConfiguration'),...
                        get_param(modelName,'CustomToolchainOptions'),...
                        false,Porting);
                        genXcelScript.doIt;

                        addNonBuildFiles(buildInfo,fullfile(pwd,[modelName,'.sh']));
                    else


                        fullBDir=RTW.transformPaths(buildInfo.getSourcePaths(true,'BuildDir'));
                        if(length(fullBDir)>1)
                            fullBDir=fullBDir(1);
                        end
                        buildInfo.addMakeVars('RELATIVE_PATH_TO_ANCHOR',fullBDir{1});
                        dpigenerator_disp(['Generating makefiles for: ',moduleName]);

                        if strcmp(get_param(modelName,'GenCodeOnly'),'off')


                            dpigenerator_disp('Invoking make to build the DPI Shared Library');
                        end
                    end

                catch ME

                    dpigenerator_setvariable;
                    rethrow(ME);
                end

            end

        case 'after_make'


            moduleName=[modelName,'_dpi'];


            IsQuestaSimTC=~isempty(strfind(buildInfo.BuildTools.Toolchain,'QuestaSim/Modelsim'));

            IsXceliumTC=~isempty(strfind(buildInfo.BuildTools.Toolchain,'Xcelium (64-bit Linux)'));

            if IsQuestaSimTC||IsXceliumTC

                [~,~]=system(['rm ',modelName,'.mk']);
                if IsQuestaSimTC
                    HDL_SimulatorName='Questasim\Modelsim';
                    ExecuteCommand='vsim';
                    ExecuteUtility='vsim';
                    Extension='.do';
                else
                    HDL_SimulatorName='Xcelium';
                    ExecuteCommand='xrun';
                    ExecuteUtility='sh';
                    Extension='.sh';
                end

                ExecuteScript=strcmp(get_param(modelName,'GenCodeOnly'),'off');

                AreBothWin32=strcmp(computer,'PCWIN')&&~isempty(strfind(buildInfo.BuildTools.Toolchain,'32-bit Windows'));
                AreBothWin64=strcmp(computer,'PCWIN64')&&~isempty(strfind(buildInfo.BuildTools.Toolchain,'64-bit Windows'));
                AreBothLinux=isunix&&(~isempty(strfind(buildInfo.BuildTools.Toolchain,'64-bit Linux'))||~isempty(strfind(buildInfo.BuildTools.Toolchain,'32-bit Linux')));
                if(AreBothWin64||AreBothWin32||AreBothLinux)&&ExecuteScript

                    dpigenerator_disp(['Executing simulator script using ',ExecuteCommand,' on system path']);

                    [status,~]=system([ExecuteCommand,' -version']);
                    if status

                        warning(message('HDLLink:DPIG:NoToolOnPath',HDL_SimulatorName));
                    else


                        [status,result]=system([ExecuteUtility,' < ',modelName,Extension]);
                        if status

                            dpigenerator_setvariable;
                            error(message('HDLLink:DPIG:SimulatorFailedToBuild',HDL_SimulatorName,result));
                        else
                            dpigenerator_disp('Successful script execution.');
                        end
                    end
                end

            end


        case 'exit'



            dpigenerator_setvariable;


            if hdlverifierfeature('IS_CODEGEN_FOR_UVM')

                hdlverifierfeature('UVM_DPIBUILD_DIR',RTW.getBuildDir(modelName).BuildDirectory);





                switch computer
                case 'PCWIN64'
                    dllExt='_win64.dll';
                otherwise
                    dllExt='.so';
                end
                if exist([modelName,dllExt],'file')~=2
                    warning(message('HDLLink:uvmgenerator:MissingDPISharedLib',[modelName,dllExt]));
                end


                SV_pkg=[modelName,'_dpi',dpig.internal.GetSVFcn.getPackageFileSuffix(),'.sv'];
                assert(exist(SV_pkg,'file')==2,message('HDLLink:uvmgenerator:MissingDPIPkg',SV_pkg));

            end
            disp(['### Successful completion of build ',...
            'procedure for model: ',modelName]);

        end

    else

        switch hookPoint
        case 'before_make'
            try





                buildInfo.addIncludePaths(fullfile(matlabroot,'simulink','include','sf_runtime'),'Standard');
                IsTSVerifyPresent=l_IncludeTSVerify(buildInfo);
                if IsTSVerifyPresent
                    FilePath=fullfile(RTW.getBuildDir(modelName).CodeGenFolder,RTW.getBuildDir(modelName).ModelRefRelativeBuildDir);
                    copyfile(fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','src','TSVerify','svdpi_verify.h'),FilePath);
                    fileattrib('svdpi_verify.h','+w');
                    buildInfo.addIncludeFiles('svdpi_verify.h',FilePath);
                    copyfile(fullfile(matlabroot,'toolbox','hdlverifier','dpigenerator','src','TSVerify','svdpi_verify.c'),FilePath);
                    fileattrib('svdpi_verify.c','+w');
                    buildInfo.addSourceFiles('svdpi_verify.c',FilePath);
                end
            catch ME

                dpigenerator_setvariable;
                rethrow(ME);
            end

        end

    end


end

function SimTime=l_getSimTime(modelName)

    stopTime=get_param(modelName,'StopTime');
    try
        SimTime=evalin('base',stopTime);
    catch
        SimTime=[];
    end

    if isempty(SimTime)
        hws=get_param(modelName,'modelworkspace');
        SimTime=hws.evalin(stopTime);
    end
end

function l_removeFileFromBuildInfo(buildInfo)
    rmIndex=[];
    for m=1:length(buildInfo.Src.Files)
        fname=buildInfo.Src.Files(m).FileName;
        if strcmp(fname,'rt_main.c')||strcmp(fname,'rt_malloc_main.c')
            rmIndex(end+1)=m;%#ok<AGROW>
        end
    end
    if~isempty(rmIndex)
        buildInfo.Src.Files(rmIndex)=[];
    end
end






























function IncludeTSVerify=l_IncludeTSVerify(buildInfo)














    IncludeTSVerify=false;

    if isempty(buildInfo)
        return;
    end



    incCell=arrayfun(@(x)(getIncludeFiles(x,true,true)),buildInfo,'UniformOutput',false);
    IncludeFiles=[incCell{:}];
    for IncFl=IncludeFiles
        if exist(IncFl{1},'file')==2
            IncludeTSVerify=contains(fileread(IncFl{1}),'svdpi_verify.h');
        end
        if IncludeTSVerify
            return;
        end
    end

end

function l_check_for_supported_tunable_prm(modelName,IsSVDPI)



    globalScope=get_param(modelName,'DataDictionary');
    var_names=slGetSpecifiedWSData(globalScope,1,1,0);
    cellfun(@(x)n_check_prm_in_sldd(modelName,x,IsSVDPI),var_names);


    TunableVars=regexp(get_param(modelName,'TunableVars'),'\w+','match');
    TunableVarsStorageClass=regexp(get_param(modelName,'TunableVarsStorageClass'),'\w+','match');
    cellfun(@(x,y)n_checkIndividual_tunPrm(x,y,IsSVDPI),TunableVarsStorageClass,TunableVars);

    function n_check_prm_in_sldd(n_modelName,n_var_name,n_IsSVDPI)
        if evalinGlobalScope(n_modelName,['isa(',n_var_name,',''Simulink.Parameter'')'])
            ParStorageClass=evalinGlobalScope(n_modelName,['get(',n_var_name,'.CoderInfo,''StorageClass'')']);
            n_checkIndividual_tunPrm(ParStorageClass,n_var_name,n_IsSVDPI);
        end
    end

    function n_checkIndividual_tunPrm(n_TunPrmStorageClass,n_PrmName,nn_IsSVDPI)
        supported_storage_class_types={Simulink.data.getNameForModelDefaultSC,...
        'Auto',...
        'ExportedGlobal',...
        'SimulinkGlobal'};

        if strcmp(n_TunPrmStorageClass,'Auto')&&~nn_IsSVDPI
            warning(message('HDLLink:DPIG:AutoTunableVarMayBeOptimized',n_PrmName));
        end

        if~any(strcmp(n_TunPrmStorageClass,supported_storage_class_types))&&~nn_IsSVDPI
            error(message('HDLLink:DPIG:BadTunableVarsStorageClass',n_PrmName,n_TunPrmStorageClass));
        end
    end
end

function l_check_dt_sz(modelName,prop,val)




    if get_param(modelName,prop)~=val
        t=MSLException(message('HDLLink:DPIG:CheckDTSZForSelectedTC',prop,val,get_param(modelName,prop)));
        t.throw();
    end

end








































