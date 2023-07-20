function build_pil_target(iMdl,timeSpan,simOpts,isMenuSim)






    if ishandle(iMdl),iMdl=get_param(iMdl,'Name');end

    simMode=get_param(iMdl,'SimulationMode');
    isSilMode=strcmpi(simMode,'software-in-the-loop (sil)');


    lIsSilAndPWS=strcmp(get_param(iMdl,'PortableWordSizes'),'on')&&isSilMode;


    lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;

    lXilCompInfo=coder.internal.utils.XilCompInfo.slCreateXilCompInfo...
    (getActiveConfigSet(iMdl),lDefaultCompInfo,lIsSilAndPWS);

    if loc_is_concurrent_execution(iMdl)
        DAStudio.error('Simulink:mds:ModelSILPILNotSupported',...
        getfullname(iMdl));
    end


    loc_check_ecoder_installed(iMdl);
    loc_check_slcoder_installed(iMdl);


    loc_check_start_time(iMdl,timeSpan);


    clientInterface=coder.connectivity.SimulinkInterface;
    configInterface=clientInterface.createConfigInterface(...
    getActiveConfigSet(iMdl),iMdl);
    coder.internal.connectivity.AutosarInterfaceStrategy.sharedValidation(configInterface);


    rtw.pil.ModelBlockPIL.checkERTTargetOrGRTTarget(configInterface);


    if(~isMenuSim)
        loc_check_simOpts_workspace(iMdl,simOpts);
    end


    loc_check_generate_ert_sfunction(iMdl);


    loc_check_masked_inports_or_outports(iMdl);


    loc_check_load_initial_state(iMdl);


    loc_check_deployment_type(iMdl);


    rtw.pil.ModelBlockPIL.validateConfiguration(isSilMode,configInterface,lXilCompInfo,false,false);

    options=coder.connectivity.VerificationOptions(isSilMode);
    options.SILDebuggingOverride=strcmp(get_param(iMdl,'SILDebugging'),'on');
    coder.connectivity.createTargetServices(configInterface,options,lXilCompInfo.XilMexCompInfo);


    if slsvTestingHook('EnableGRTSILTesting')==0
        builtin('license','checkout','RTW_Embedded_Coder');
        builtin('license','checkout','Real-Time_Workshop');
    end





    topModel=iMdl;
    xilComponentModel=iMdl;
    topModelAccelWithTimeProfiling=false;
    topModelAccelWithStackProfiling=false;
    isXILSubsystemHiddenModelBuild=false;

    rtw.pil.ModelBlockPIL.XILBuildOneStandaloneTarget(topModel,...
    xilComponentModel,...
    isSilMode,...
    isMenuSim,...
    lDefaultCompInfo,...
    lXilCompInfo,...
    topModelAccelWithTimeProfiling,...
    topModelAccelWithStackProfiling,...
    isXILSubsystemHiddenModelBuild);

    function loc_check_generate_ert_sfunction(iMdl)

        if strcmp(get_param(iMdl,'CreateSILPILBlock'),'SIL')&&...
            strcmp(silblocktype,'legacy')
            rtw.pil.ProductInfo.error('pil','TopModelPilGenerateErtSFunction',...
            iMdl)
        end

        function loc_check_load_initial_state(iMdl)
            if strcmp(get_param(iMdl,'LoadInitialState'),'on')
                rtw.pil.ProductInfo.error('pil','TopModelPilLoadInitialState',...
                iMdl)
            end

            function loc_check_start_time(iMdl,timeSpan)

                if(length(timeSpan)>1)
                    if~isequal(0,timeSpan(1))
                        rtw.pil.ProductInfo.error('pil','TopModelPilStartTime',...
                        iMdl)
                    end
                end

                function loc_check_ecoder_installed(iMdl)

                    if slsvTestingHook('EnableGRTSILTesting')==0&&...
                        ~ecoderinstalled()
                        DAStudio.error('Simulink:tools:TopModelPilERT',...
                        iMdl);
                    end

                    function loc_check_slcoder_installed(iMdl)

                        if~coder.internal.getSimulinkCoderLicenseState
                            DAStudio.error('Simulink:tools:TopModelPilSLC',...
                            iMdl);
                        end

                        function loc_check_simOpts_workspace(iMdl,simOpts)


                            if((isfield(simOpts,'SrcWorkspace')&&...
                                ~isempty(simOpts.SrcWorkspace)&&...
                                ~strcmp('base',simOpts.SrcWorkspace)))
                                rtw.pil.ProductInfo.error('pil','TopModelPilSrcWorkspace',...
                                iMdl,simOpts.SrcWorkspace);
                            end
                            if((isfield(simOpts,'DstWorkspace')&&...
                                strcmp('parent',simOpts.DstWorkspace)))
                                rtw.pil.ProductInfo.error('pil','TopModelPilDstWorkspace',...
                                iMdl);
                            end


                            function loc_check_masked_inports_or_outports(iMdl)


                                Inports=find_system(iMdl,'SearchDepth',1,...
                                'BlockType','Inport');


                                if(any(strcmp('on',get_param(Inports,'Mask'))))
                                    rtw.pil.ProductInfo.error('pil','TopModelPilMaskedPorts',...
                                    iMdl);
                                end

                                Outports=find_system(iMdl,'SearchDepth',1,...
                                'BlockType','Outport');


                                if(any(strcmp('on',get_param(Outports,'Mask'))))
                                    rtw.pil.ProductInfo.error('pil','TopModelPilMaskedPorts',...
                                    iMdl);
                                end

                                function ret=loc_is_concurrent_execution(model)

                                    configSet=getActiveConfigSet(model);
                                    ret=DeploymentDiagram.isExtendedConfigSetForConcurrency(configSet);

                                    function loc_check_deployment_type(iMdl)



                                        mapping=Simulink.CodeMapping.getCurrentMapping(iMdl);
                                        if~isempty(mapping)&&isprop(mapping,'DeploymentType')
                                            platformType=coder.dictionary.internal.getPlatformType(iMdl);
                                            switch platformType
                                            case 'ApplicationPlatform'
                                                allowedDeploymentType='Unset';
                                                suggestedDeploymentType='Automatic';
                                            case 'FunctionPlatform'
                                                allowedDeploymentType='Component';
                                                suggestedDeploymentType=allowedDeploymentType;
                                            otherwise
                                                assert(false,'Platform type should be either Application or Function');
                                            end
                                            if~strcmp(mapping.DeploymentType,allowedDeploymentType)
                                                error(message('PIL:pil:DeploymentTypeNotSupportedForTopModel',...
                                                iMdl,suggestedDeploymentType));
                                            end
                                        end


