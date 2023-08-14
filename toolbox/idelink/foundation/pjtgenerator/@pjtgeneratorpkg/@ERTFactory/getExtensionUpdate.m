function getExtensionUpdate(hObj,event)




    if strcmp(event,'attach')

        registerPropList(hObj,'NoDuplicate','All',[]);
    elseif strcmp(event,'switch_target')
        if~exist('registertic2000.m','file')&&...
            ~exist('registerxilinxise.m','file')
            return;
        end
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
                if strcmp(get_param(cs,'IsCPPClassGenMode'),'on')
                    Simulink.CPPComponent.attachCPPComponent(hObj);
                end
            end
        end


        setLinkDependentOptionStatus(cs);
        setLinkDependentOptionEnable(cs);
        linkfoundation.util.addTargetHardwareResourceComponent(hObj,-1,'switch');
        trg=linkfoundation.util.getTargetComponent(cs);
        if cs.isValidParam('AdaptorName')&&~isempty(get_param(cs,'AdaptorName'))
            trg.setAdaptor(get_param(cs,'AdaptorName'));
        end

        cs.setProp('IgnoreCustomStorageClasses','off');
        set_param(cs,'InlineParams','off');
        set_param(cs,'TargetLangStandard','C89/C90 (ANSI)');

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
            if(strcmp(get_param(hObj,'PortableWordSizes'),'on')&&strcmp(get_param(getConfigSet(hObj),'ProdEqTarget'),'off'))
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
        linkfoundation.util.addTargetHardwareResourceComponent(hObj,-1,'activate');
        hObj.updateParametersForOldModels();
    elseif strcmp(event,'deselect_target')
        cs=hObj.getConfigSet();
        cs.setPropEnabled('MaxStackSize','on');
        if~cs.isHierarchyBuilding


            if~isempty(cs.getComponent('Target Hardware Resources'))&&...
                isempty(find_system(cs.getModel(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Target Preferences'))

                cs.detachComponent('Target Hardware Resources');
            end
        end
    end



    function linkManageActivateEvent(hObj)




        hObj.AdaptorName=strrep(hObj.AdaptorName,'TI Code Composer','Texas Instruments Code Composer');
        hObj.AdaptorName=strrep(hObj.AdaptorName,'ADI VisualDSP','Analog Devices VisualDSP');
        hObj.AdaptorName=strrep(hObj.AdaptorName,'GHS MULTI','Green Hills MULTI');

        cs=hObj.getConfigSet();
        setLinkDependentOptionEnable(cs);


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
                    cs.setProp('MaxStackSize','Inherit from target');
                    cs.setPropEnabled('MaxStackSize','off');
                    cs.setPropEnabled('ERTFilePackagingFormat','on');
                    cs.setProp('ERTFilePackagingFormat','Modular');
                    cs.setPropEnabled('ERTFilePackagingFormat','off');
                    cs.setProp('GRTInterface','off');
                    cs.setPropEnabled('GRTInterface','off');
                end
