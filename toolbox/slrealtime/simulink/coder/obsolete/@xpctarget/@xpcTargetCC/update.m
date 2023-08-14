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
        set_param(hConf,'RTWCompilerOptimization','on');

        setOptionsAlways(hSrc);


        set_param(hConf,'InlineInvariantSignals','off');
        set_param(hConf,'BlockReduction','off');
        set_param(hConf,'OptimizeBlockIOStorage','off');
        set_param(hConf,'BufferReuse','off');
        set_param(hConf,'LocalBlockOutputs','off');
        set_param(hConf,'ExpressionFolding','off');






        set_param(hConf,'EnableMultiTasking','on');
        set_param(hConf,'AutoInsertRateTranBlk','on');
        set_param(hConf,'ConcurrentTasks','on');


        set_param(hConf,'xPCConcurrentTasks','on');


        set_param(hConf,'MultiTaskCondExecSysMsg','error')
        set_param(hConf,'MultiTaskDSMMsg','error');













        if~isempty(hConf.getModel)
            model=hConf.getModel;
            if~strcmp(get_param(model,'BlockDiagramType'),'library')


                dt=get_param(model,'dirty');
                datatransf=get_param(model,'DataTransfer');
                datatransf.AutoInsertRateTranBlk=1;
                datatransf.DefaultTransitionBetweenSyncTasks='Ensure data integrity only';
                datatransf.DefaultTransitionBetweenContTasks='Ensure data integrity only';
                set_param(model,'dirty',dt);
            end
        end


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

            set_param(hConf,'CodeReplacementLibrary','XPC_BLAS');

            set_param(hConf,'MatFileLogging','on');




            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',true);
            slConfigUISetVal(hConf,hSrc,'ProdLongLongMode','on');
            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',false);










