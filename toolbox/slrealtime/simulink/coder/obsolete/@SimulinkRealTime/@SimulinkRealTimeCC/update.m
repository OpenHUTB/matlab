function update(hSrc,event)






    if nargin>1
        event=convertStringsToChars(event);
    end

    hConf=hSrc.getConfigSet;
    if isempty(hConf)&&~strcmp(event,'attach')
        return
    end








    switch event
    case 'attach'
        registerPropList(hSrc,'NoDuplicate','All',[]);
    case 'switch_target'
        setOptionsOnSwitch(hSrc,hConf);
    case 'activate'
        setOptionsAlways(hSrc,hConf);
    otherwise

    end

    function setOptionsOnSwitch(hSrc,hConf)


        if evalin('base','exist(''oldxpcstf'') == 1')
            return
        end

        setOptionsAlways(hSrc,hConf);




        set_param(hConf,'RTWCompilerOptimization','on');

        set_param(hConf,'InlineInvariantSignals','off');
        set_param(hConf,'BlockReduction','off');



        set_param(hConf,'OptimizeBlockIOStorage','off');

        set_param(hConf,'SaveFormat','StructureWithTime');







        hConf.setProp('EnableMultiTasking','on');
        hConf.setProp('AutoInsertRateTranBlk','on');
        hConf.setProp('ConcurrentTasks','on');


        set_param(hConf,'xPCConcurrentTasks','on');


        set_param(hConf,'MultiTaskCondExecSysMsg','error')
        set_param(hConf,'MultiTaskDSMMsg','error');













        if~isempty(hConf.getModel)&&strcmp(get(hConf.getModel,'BlockDiagramType'),'model')
            datatransf=get(hConf.getModel,'DataTransfer');
            datatransf.DefaultTransitionBetweenSyncTasks='Ensure data integrity only';
            datatransf.DefaultTransitionBetweenContTasks='Ensure data integrity only';
        end





        set_param(hConf,'Toolchain',coder.make.internal.getInfo('default-toolchain'));

        function setOptionsAlways(hSrc,hConf)


            set_param(hConf,'CompOptLevelCompliant','on');
            set_param(hConf,'IncludeRegionsInRTWFileBlockHierarchyMap','on');

            slConfigUISetVal(hConf,hSrc,'TargetLang','C');
            slConfigUISetEnabled(hConf,hSrc,'TargetLang','off');

            set_param(hConf,'ModelReferenceCompliant','on');
            set_param(hConf,'ParMdlRefBuildCompliant',true);
            set_param(hConf,'ConcurrentExecutionCompliant','on');

            set_param(hConf,'MatFileLogging','on');
            slConfigUISetEnabled(hConf,hSrc,'MatFileLogging',false);

            slConfigUISetVal(hConf,hSrc,'ProdHWDeviceType','Generic->32-bit x86 compatible');
            slConfigUISetEnabled(hConf,hSrc,'ProdHWDeviceType',false);
            set_param(hConf,'ProdEqTarget','on');




            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',true);
            slConfigUISetVal(hConf,hSrc,'ProdLongLongMode','on');
            slConfigUISetEnabled(hConf,hSrc,'ProdLongLongMode',false);

            slConfigUISetVal(hConf,hSrc,'GRTInterface','on');
            slConfigUISetEnabled(hConf,hSrc,'GRTInterface',false);










            set_param(hConf,'TargetLangStandard','C89/C90 (ANSI)');





            hConf.setPropEnabled('CodeProfilingInstrumentation',1);
            hConf.setPropEnabled('CodeExecutionProfiling',1);
            set_param(hConf,'CodeExecutionProfiling','off');
            slConfigUISetEnabled(hConf,hSrc,'CodeExecutionProfiling',true);



            set_param(hConf,'ArrayLayout','Column-major');
            slConfigUISetEnabled(hConf,hSrc,'ArrayLayout',false);
            set_param(hConf,'UseRowMajorAlgorithm',false);
            slConfigUISetEnabled(hConf,hSrc,'UseRowMajorAlgorithm',false);




