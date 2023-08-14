function lBuildOptsInstr=createBuildOptsCompileInstr...
    (lBuildOpts,lIsSilAndPws,lIsSILDebuggingEnabled,...
    lToolchainOrTMFInstr,mainBuildInfo)




    lBuildOptsInstr=copy(lBuildOpts);
    if lIsSilAndPws

        lBuildOptsInstr.MakefileBasedBuild=true;



        lBuildOptsInstr.sysTargetFile='';

        lBuildConfiguration=...
        coder.make.ToolchainInfo.getDefaultBuildConfig;
        lCustomToolchainOptions={};
        if lIsSILDebuggingEnabled

            [lBuildConfiguration,lCustomToolchainOptions]=...
            coder.internal.overrideBuildConfigAndOptionsForDebug...
            (lToolchainOrTMFInstr,lBuildConfiguration,...
            lCustomToolchainOptions,mainBuildInfo);
        end
        lBuildOptsInstr.BuildConfiguration=lBuildConfiguration;
        lBuildOptsInstr.CustomToolchainOptions=lCustomToolchainOptions;


        lBuildOptsInstr.LegacyTargetLibSuffix='';
    end
