function update(hObj,event)




    event=convertStringsToChars(event);


    if strcmp(event,'attach')


        registerPropList(hObj,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')

        hParent=getParent(hObj);

        if isa(hParent,'Simulink.STFCustomTargetCC')
            hParent=getParent(hParent);
        end

        if~isempty(hParent)&&isa(hParent,'Simulink.RTWCC')
            hCodeApp=getComponent(hParent,'Code Appearance');
            set(hCodeApp,'IgnoreCustomStorageClasses','off');


            if isequal(get_param(hParent,'GenerateReport'),'on')
                set_param(hParent,'IncludeHyperlinkInReport','on');
            end
        end

        if~isempty(hObj.getConfigSet)&&strcmp(hObj.InMdlLoading,'off')
            if~isempty(hObj.TargetID)&&isfield(hObj.TargetID,'MakeCommand')&&...
                exist('ert_config_opt','file')&&nargin('ert_config_opt')==-1
                if~isempty(findstr(hObj.TargetID.MakeCommand,'optimized_fixed_point'))
                    ert_config_opt(hParent.getConfigSet,'optimized_fixed_point');
                elseif~isempty(findstr(hObj.TargetID.MakeCommand,'optimized_floating_point'))
                    ert_config_opt(hParent.getConfigSet,'optimized_floating_point');
                end
            end
        end

        if~isempty(hObj.getConfigSet)
            set_param(hObj.getConfigSet,'LifeSpan','1');
        end

        cs=hObj.getConfigSet();
        if~isempty(cs)
            if rtwprivate('isCPPClassGenEnabled',cs)
                if strcmpi(get_param(cs,'IsCPPClassGenMode'),'on')
                    Simulink.CPPComponent.attachCPPComponent(hObj);
                end

            end
        end


        setLinkDependentOptionStatus(cs);
        setLinkDependentOptionEnable(cs);
        cs.setProp('IgnoreCustomStorageClasses','off');

    elseif strcmp(event,'update_host_model')
        model=get_param(hObj.getModel,'Name');


        if strcmp(get_param(hObj,'PurelyIntegerCode'),'on')






            if strcmp(get_param(hObj,'SupportNonInlinedSFcns'),'on')
                MSLDiagnostic('RTW:configSet:mayNeedFloatingPointSupport').reportAsWarning;
            end

            if strcmp(get_param(hObj,'MatFileLogging'),'on')
                throw(MSLException([],message('RTW:configSet:requireFloatingPointSupport',model)));
            end
            if strcmp(get_param(hObj,'GRTInterface'),'on')
                throw(MSLException([],message('RTW:configSet:requireFloatingPointSupportForGRTInterface',model)));
            end
        end







        if strcmp(get_param(hObj,'SupportNonFinite'),'on')
            if strcmp(get_param(hObj,'PurelyIntegerCode'),'on')
                MSLDiagnostic('RTW:configSet:cannotSupportNonFinite').reportAsWarning;
            end
        else
            if strcmp(get_param(hObj,'MatFileLogging'),'on')
                throw(MSLException([],message('RTW:configSet:requireNonFiniteSupport',model)));
            end
            if strcmp(get_param(hObj,'SupportNonInlinedSFcns'),'on')
                MSLDiagnostic('RTW:configSet:mayNeedNonFiniteSupport').reportAsWarning;
            end
        end







        if~isempty(hObj.getConfigSet)
            if(strcmp(get_param(getConfigSet(hObj),'PortableWordSizes'),'on')&&strcmp(get_param(getConfigSet(hObj),'ProdEqTarget'),'off'))
                DAStudio.error('RTW:configSet:emulationSettingConflict');
            end
        end




        if~isempty(hObj.getConfigSet)
            if(strcmp(get_param(hObj,'GRTInterface'),'on')&&strcmp(get_param(getConfigSet(hObj),'CreateSILPILBlock'),'SIL')...
                &&strcmp(silblocktype,'legacy'))
                DAStudio.error('RTW:configSet:cannotGenGRTInterfaceAndERTSfun');
            end
        end






        if strcmp(get_param(hObj,'CombineOutputUpdateFcns'),'on')&&...
            strcmp(get_param(hObj,'GRTInterface'),'on')
            throw(MSLException([],message('RTW:configSet:cannotCombineOutputUpdateFcns',model)));
        end


        if strcmp(get_param(hObj,'IncludeMdlTerminateFcn'),'off')&&...
            strcmp(get_param(hObj,'MatFileLogging'),'on')
            DAStudio.error('RTW:configSet:matfileLoggingMustIncludeTerminateFcn');
        end


        if strcmp(get_param(hObj,'MatFileLogging'),'on')&&...
            strcmp(get_param(hObj,'SuppressErrorStatus'),'on')
            throw(MSLException([],message('RTW:configSet:cannotSuppressErrorStatus',model)));
        end

        hParent=getParent(hObj);
        if isa(hParent,'Simulink.STFCustomTargetCC')
            hParent=getParent(hParent);
        end


        if~isempty(hParent)&&isa(hParent,'Simulink.RTWCC')

            coder.internal.slcoderReport('checkCommentOptions',hParent);
        end
    elseif strcmp(event,'activate')

        linkManageActivateEvent(hObj);
        linkfoundation.pjtgenerator.updateStf(hObj);


    end



    function linkManageActivateEvent(hObj)

        cs=hObj.getConfigSet();
        setLinkDependentOptionEnable(cs);
        if~isempty(cs)
            if~strcmp(get_param(cs,'buildAction'),'Create_Processor_In_the_Loop_project')&&...
                strcmp(get_param(cs,'configurePIL'),'on')
                cs.setProp('buildAction','Create_Processor_In_the_Loop_project');
            end
            if strcmp(cs.getProp('buildAction'),'Create_Processor_In_the_Loop_project')










                pilConfig=rtw.pil.ConfigureModelForPILBlock(cs);

                pilConfig.configure;

            end
        end



        function setLinkDependentOptionStatus(cs)

            if~isempty(cs)
                cs.setProp('ProdEqTarget','on');
                cs.setProp('GenerateSampleERTMain','off');
                cs.setProp('GenCodeOnly','off');
                cs.setProp('GenerateMakefile','off');
                cs.setProp('ModelStepFunctionPrototypeControlCompliant','on');
            end



            function setLinkDependentOptionEnable(cs)
                if~isempty(cs)
                    cs.setPropEnabled('ProdEqTarget','on');
                    cs.setPropEnabled('GenCodeOnly','on');
                    cs.setProp('GenCodeOnly','off');
                    cs.setPropEnabled('GenCodeOnly','off');
                    cs.setPropEnabled('GenerateSampleERTMain','off');
                    cs.setPropEnabled('GenerateMakefile','off');
                    cs.setProp('ModelStepFunctionPrototypeControlCompliant','on');
                end
