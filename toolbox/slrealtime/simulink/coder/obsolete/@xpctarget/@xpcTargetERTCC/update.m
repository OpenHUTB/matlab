function update(hSrc,event)





    if nargin>1
        event=convertStringsToChars(event);
    end

    switch event
    case 'attach'
        registerPropList(hSrc,'NoDuplicate','All',[]);
    case 'switch_target'
        setOptionsOnSwitch(hSrc);
    case 'activate'
        setOptionsAlways(hSrc);
    otherwise

    end

    function setOptionsOnSwitch(hSrc)

        hConf=hSrc.getConfigSet;
        if isempty(hConf)
            return
        end


        set_param(hConf,'CompOptLevelCompliant','on');



        if evalin('base','exist(''oldxpcstf'') == 1')
            return
        end


        set_param(hConf,'RTWCompilerOptimization','on');

        setOptionsAlways(hSrc);



        set_param(hConf,'InlineInvariantSignals','off');
        set_param(hConf,'BlockReduction','off');
        set_param(hConf,'OptimizeBlockIOStorage','off');
        set_param(hConf,'BufferReuse','off');
        set_param(hConf,'LocalBlockOutputs','off');

        set_param(hConf,'ExpressionFolding','off');


        function setOptionsAlways(hSrc)


            hConf=hSrc.getConfigSet;
            if isempty(hConf)
                return
            end

            set_param(hConf,'EnableConcurrentExecution','on');
            set_param(hConf,'IncludeRegionsInRTWFileBlockHierarchyMap','on');
            set_param(hConf,'ProdHWDeviceType','Generic->32-bit x86 compatible');
            set_param(hConf,'ProdEqTarget','on');
            set_param(hConf,'TargetLang','C');

            set_param(hConf,'ModelReferenceCompliant','on');
            set_param(hConf,'ParMdlRefBuildCompliant',true);
            set_param(hConf,'ConcurrentExecutionCompliant','on');

            support_opt_setting=get_param(hConf,'CompOptLevelCompliant');
            if strcmpi(support_opt_setting,'off')


                set_param(hConf,'CompOptLevelCompliant','on');
                set_param(hConf,'RTWCompilerOptimization','on');
            end

            set_param(hConf,'MatFileLogging','on');




            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',true);
            slConfigUISetVal(hConf,hSrc,'ProdLongLongMode','on');
            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',false);


            set_param(hConf,'RTWCAPIParams','on');









            tfl=get_param(hConf,'CodeReplacementLibrary');

            if strcmpi(tfl,'none')||RTW.isTflEq(tfl,'ANSI_C')
                set_param(hConf,'CodeReplacementLibrary','XPC_BLAS');
            end



