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
        setOptionsOnSwitch(hConf);
    case 'activate'
        setOptionsAlways(hConf);
    otherwise

    end

    function setOptionsOnSwitch(hConf)

        setOptionsAlways(hConf);




        set_param(hConf,'BuildConfiguration','Faster Runs');

        set_param(hConf,'InlineInvariantSignals','off');
        set_param(hConf,'BlockReduction','off');



        set_param(hConf,'OptimizeBlockIOStorage','off');

        set_param(hConf,'TargetLangStandard','C++03 (ISO)');

        function setOptionsAlways(hConf)



            set_param(hConf,'UseToolchainInfoCompliant','on');
            set_param(hConf,'GenerateMakefile','on');
            set_param(hConf,'RTWCompilerOptimization','off');
            set_param(hConf,'MakeCommand','make_rtw');
            hConf.setPropEnabled('RTWCompilerOptimization',false);
            hConf.setPropEnabled('MakeCommand',false);

            if~ismac


                set_param(hConf,'Toolchain','Simulink Real-Time Toolchain');
                hConf.setPropEnabled('Toolchain',false);
            end


            set_param(hConf,'CompOptLevelCompliant','on');
            set_param(hConf,'IncludeRegionsInRTWFileBlockHierarchyMap','on');

            set_param(hConf,'TargetLang','C++');
            hConf.setPropEnabled('TargetLang',false);

            hConf.setPropEnabled('CodeInterfacePackaging',true);
            set_param(hConf,'CodeInterfacePackaging','Nonreusable function');
            hConf.setPropEnabled('CodeInterfacePackaging',false);

            set_param(hConf,'ModelReferenceCompliant','on');
            set_param(hConf,'ParMdlRefBuildCompliant',true);
            set_param(hConf,'ConcurrentExecutionCompliant','on');
            set_param(hConf,'TasksWithSamePriorityMsg','none');
            hConf.setPropEnabled('TasksWithSamePriorityMsg',false);

            set_param(hConf,'MatFileLogging','off');
            hConf.setPropEnabled('MatFileLogging',false);

            hConf.setPropEnabled('ProdHWDeviceType',true);
            set_param(hConf,'ProdHWDeviceType','Intel->x86-64 (Linux 64)');
            hConf.setPropEnabled('ProdHWDeviceType',false);
            set_param(hConf,'ProdEqTarget','on');




            hConf.setPropEnabled('ProdLongLongMode',true);
            set_param(hConf,'ProdLongLongMode','on');
            hConf.setPropEnabled('ProdLongLongMode',false);

            set_param(hConf,'GRTInterface','off');
            hConf.setPropEnabled('GRTInterface',false);


            set_param(hConf,'CombineOutputUpdateFcns','on');
            hConf.setPropEnabled('CombineOutputUpdateFcns',false);

            set_param(hConf,'CodeReplacementLibrary','Simulink Real-Time CRL');
            hConf.setPropEnabled('CodeReplacementLibrary',false);


            hConf.setPropEnabled('GenerateASAP2',true);
            set_param(hConf,'GenerateASAP2','off');
            hConf.setPropEnabled('GenerateASAP2',false);





            hConf.setPropEnabled('CodeProfilingInstrumentation',true);
            hConf.setPropEnabled('CodeExecutionProfiling',true);
            set_param(hConf,'CodeExecutionProfiling','on');
            hConf.setPropEnabled('CodeExecutionProfiling',false);



            set_param(hConf,'ArrayLayout','Column-major');
            hConf.setPropEnabled('ArrayLayout',false);
            set_param(hConf,'UseRowMajorAlgorithm',false);
            hConf.setPropEnabled('UseRowMajorAlgorithm',false);



            hConf.setPropEnabled('SampleTimeConstraint',true);


            setProp(hConf,'SampleTimeConstraint','unconstrained');
            hConf.setPropEnabled('SampleTimeConstraint',false);

            hConf.setPropEnabled('PositivePriorityOrder',true);
            set_param(hConf,'PositivePriorityOrder','on');
            hConf.setPropEnabled('PositivePriorityOrder',false);





            set_param(hConf,'ConcurrentTasks','on');


            set_param(hConf,'MultiTaskCondExecSysMsg','error');
            set_param(hConf,'MultiTaskDSMMsg','error');

            set_param(hConf,'PackageGeneratedCodeAndArtifacts','off');
            hConf.setPropEnabled('PackageGeneratedCodeAndArtifacts',false);



            hConf.setPropEnabled('ExtModeTransport',true);
            set_param(hConf,'ExtModeTransport',...
            Simulink.ExtMode.Transports.getExtModeTransportIndex(...
            hConf,Simulink.ExtMode.Transports.SLRTXCP.Transport));
            hConf.setPropEnabled('ExtModeTransport',false);
