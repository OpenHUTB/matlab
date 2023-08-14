function addRsimInfo(buildInfo,cs,solverMode,lRSIMWithSlSolver,ext,...
    targetType,libsf,lMLSysLibPath)




    standardGroup=coder.make.internal.BuildInfoGroup.BiStandardGroup;
    legacyGroup=coder.make.internal.BuildInfoGroup.BiLegacyGroup;

    if strcmp(computer('arch'),'glnxa64')

        addLinkFlags(buildInfo,'-Wl,--allow-shlib-undefined');
    end


    if ismac&&strcmp(targetType,'NONE')
        mlBinFolder=fullfile(matlabroot,'bin',computer('arch'));
        macLdFlags={sprintf('-Wl,-rpath,%s',mlBinFolder),...
        '-Wl,-rpath,@executable_path'};
        addLinkFlags(buildInfo,macLdFlags);
    end

    addTMFTokens(buildInfo,'|>MAT_FILE<|','1');

    if isunix&&~ismac
        buildInfo.addCompileFlags('-Wno-cast-function-type','OPTS');
    end


    if lRSIMWithSlSolver
        optDefines={'NRT','RSIM_WITH_SL_SOLVER'};
    else
        optDefines={'RT'};
    end


    customDefines={'IS_RSIM'};


    if strcmp(solverMode,'MultiTasking')
        optDefines{end+1}='RSIM_WITH_SOLVER_MULTITASKING';
    end


    lExtMode=get_param(cs,'ExtMode');
    rsimParamLoading=contains...
    (get_param(getModel(cs),'RTWBuildArgs'),'RSIM_PARAMETER_LOADING=1');
    if strcmp('on',lExtMode)||rsimParamLoading
        optDefines{end+1}='RSIM_PARAMETER_LOADING';
    end


    addDefines(buildInfo,customDefines,coder.make.internal.BuildInfoGroup.DefinesCustomGroup);


    addDefines(buildInfo,optDefines,coder.make.internal.BuildInfoGroup.DefinesOptsGroup);

    rsimIncPaths={fullfile(matlabroot,'rtw','c','src','rapid')...
    ,fullfile(matlabroot,'rtw','c','rsim')...
    ,fullfile(matlabroot,'rtw','c','src','ext_mode','common')};
    rsimIncGroups=repmat({standardGroup},1,length(rsimIncPaths));

    addIncludePaths(buildInfo,rsimIncPaths,rsimIncGroups);

    if strcmp(targetType,'NONE')

        noMdlRefFiles={['rsim_main',ext]...
        ,'rsim_sup.c'...
        ,'rsim_mat.c'...
        ,'simulink_solver_api.c'...
        ,'rsim_utils.c'...
        ,'common_utils.c'};
        noMdlRefFilePaths={fullfile(matlabroot,'rtw','c','rsim'),...
        fullfile(matlabroot,'rtw','c','rsim'),...
        fullfile(matlabroot,'rtw','c','rsim'),...
        fullfile(matlabroot,'simulink','include'),...
        fullfile(matlabroot,'rtw','c','src','rapid'),...
        fullfile(matlabroot,'rtw','c','src','rapid')};
        noMdlRefFileGroups=repmat({legacyGroup},1,length(noMdlRefFiles));

        if~lRSIMWithSlSolver&&strcmp(targetType,'NONE')
            noMdlRefFiles{end+1}='rt_sim.c';
            noMdlRefFilePaths{end+1}=fullfile(matlabroot,'rtw','c','src');
            noMdlRefFileGroups{end+1}=legacyGroup;
        end
        addSourceFiles(buildInfo,noMdlRefFiles,noMdlRefFilePaths,noMdlRefFileGroups);

        i_addSysLibs(lRSIMWithSlSolver,buildInfo,libsf,lMLSysLibPath,...
        standardGroup);
    end



    if slfeature('64BlockIO')
        compilerInfo=coder.make.internal.getMexCompilerInfo;
        if~isempty(compilerInfo)&&strcmp(compilerInfo.toolChain,'vcx64')
            addLinkFlags(buildInfo,'-LARGEADDRESSAWARE');
        elseif~ismac
            addCompileFlags(buildInfo,'-mcmodel=medium');
        end
    end



    function i_addSysLibs(lRSIMWithSlSolver,buildInfo,libsf,lMLSysLibPath,...
        standardGroup)

        sysLibs={...
'mat'...
        ,'mx'...
        ,'ut'...
        ,'mwsl_fileio'...
        ,'mwsl_simtarget_instrumentation'...
        ,'mwi18n'...
        ,'mwsigstream'...
        ,'mwsl_AsyncioQueue'...
        ,libsf};
        sysLibPaths=repmat({lMLSysLibPath},1,length(sysLibs));
        sysLibGroups=repmat({standardGroup},1,length(sysLibs));

        if lRSIMWithSlSolver
            sysLibs=[sysLibs,'mwsl_solver_rtw'];
            sysLibPaths=[sysLibPaths,{lMLSysLibPath}];
            sysLibGroups=[sysLibGroups,standardGroup];
        end
        if strcmp(computer('arch'),'maci64')
            sysLibs=[sysLibs,'dl'];
            sysLibPaths=[sysLibPaths,{''}];
            sysLibGroups=[sysLibGroups,standardGroup];
        end

        addSysLibs(buildInfo,sysLibs,sysLibPaths,sysLibGroups);
