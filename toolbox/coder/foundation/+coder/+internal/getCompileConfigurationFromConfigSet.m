function[lBuildConfiguration,lCustomToolchainOptions]=...
    getCompileConfigurationFromConfigSet(cs,lIsTMFBased,lToolchainInfo)





    isRsimOrRtwsfcn=...
    any(strcmp(get_param(cs,'SystemTargetFile'),{'rsim.tlc','rtwsfcn.tlc'}));
    lRTWCompilerOptimization=get_param(cs,'RTWCompilerOptimization');
    lCompOptLevelCompliant=get_param(cs,'CompOptLevelCompliant');
    lBuildConfigurationCSParam=get_param(cs,'BuildConfiguration');
    lCustomToolchainOptionsCSParam=get_param(cs,'CustomToolchainOptions');
    lRTWCustomCompilerOptimizations=get_param(cs,'RTWCustomCompilerOptimizations');





    assert(any(strcmp(lRTWCompilerOptimization,{'off','on','Custom'})),...
    'lRTWCompilerOptimization must be one of allowed values')







    lMinGWUseOptLevel=i_getMinGWUseOptLevel...
    (lToolchainInfo,isRsimOrRtwsfcn,lRTWCompilerOptimization);



    lOptLevelCompliantTMF=lIsTMFBased&&strcmp(lCompOptLevelCompliant,'on');





    useRTWCompilerOptimization=lMinGWUseOptLevel||lOptLevelCompliantTMF;

    if useRTWCompilerOptimization


        [lBuildConfiguration,lCustomToolchainOptions]=i_mapSimOrRTWOptsToBuildConf...
        (lRTWCompilerOptimization,lRTWCustomCompilerOptimizations);
    elseif~isempty(lToolchainInfo)

        lBuildConfiguration=lBuildConfigurationCSParam;
        if isempty(lBuildConfiguration)
            lBuildConfiguration='Faster Builds';
        end
        lCustomToolchainOptions=lCustomToolchainOptionsCSParam;
        if isempty(lCustomToolchainOptions)
            lCustomToolchainOptions={};
        end
    else

        lBuildConfiguration='Specify';
        lCustomToolchainOptions={};
    end




    function[lBuildConfiguration,lCustomToolchainOptions]=i_mapSimOrRTWOptsToBuildConf...
        (lRTWCompilerOptimization,lRTWCustomCompilerOptimizations)

        switch lRTWCompilerOptimization
        case 'off'
            lBuildConfiguration='Faster Builds';
            lCustomToolchainOptions={};
        case 'on'
            lBuildConfiguration='Faster Runs';
            lCustomToolchainOptions={};
        otherwise
            lBuildConfiguration='Specify';


            lCustomToolchainOptions={'C Compiler',lRTWCustomCompilerOptimizations};

        end



        function lMinGWUseOptLevel=i_getMinGWUseOptLevel...
            (lToolchainInfo,isRsimOrRtwsfcn,lRTWCompilerOptimization)


            lAlwaysToolchainInfoCompliant=...
            ~isempty(lToolchainInfo)&&...
            lToolchainInfo.isAttribute('AlwaysToolchainInfoCompliant');
            if lAlwaysToolchainInfoCompliant




                lMinGWUseOptLevel=...
                lAlwaysToolchainInfoCompliant&&isRsimOrRtwsfcn&&strcmp(lRTWCompilerOptimization,'on');
            else
                lMinGWUseOptLevel=false;
            end
