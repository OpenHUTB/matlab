function update(hObj,event)





    if strcmp(event,'attach')

        registerPropList(hObj,'NoDuplicate','All',[]);

        cs=hObj.getConfigSet;
        if~isempty(cs)
            if(slfeature('InlinePrmsAsCodeGenOnlyOption')~=1&&...
                (strcmp(get_param(cs,'InlineParams'),'off')))
                setProp(hObj,'InlinedParameterPlacement','Hierarchical');
            end
        end

        setToolchainInfoCompliance(hObj);
    elseif strcmp(event,'switch_target')
        hParent=getParent(hObj);



        ertEnabled=strcmp(get_param(hObj,'IsERTTarget'),'on');

        if isa(hParent,'Simulink.STFCustomTargetCC')
            hParent=getParent(hParent);
        end

        if~isempty(hParent)&&isa(hParent,'Simulink.RTWCC')
            hCodeApp=getComponent(hParent,'Code Appearance');
            if ertEnabled
                hCodeApp.IgnoreCustomStorageClasses='off';
            end
        end

        cs=hObj.getConfigSet();
        if~isempty(cs)&&ertEnabled
            configset.ert.setDefaults(hObj,cs);
        end


        if~isempty(hObj.getConfigSet)&&strcmp(hObj.InMdlLoading,'off')
            if~isempty(hObj.TargetID)&&isfield(hObj.TargetID,'MakeCommand')&&...
                exist('ert_config_opt','file')&&nargin('ert_config_opt')==-1
                if~isempty(findstr(hObj.TargetID.MakeCommand,'optimized_fixed_point'))%#ok<FSTR>
                    ert_config_opt(hParent.getConfigSet,'optimized_fixed_point');
                elseif~isempty(findstr(hObj.TargetID.MakeCommand,'optimized_floating_point'))%#ok<FSTR>
                    ert_config_opt(hParent.getConfigSet,'optimized_floating_point');
                end
            end
        end

        setToolchainInfoCompliance(hObj);

    elseif strcmp(event,'detach')



        cs=hObj.getConfigSet();
        if~isempty(cs)
            componentOpt=cs.getComponent('Optimization');
            componentOpt.assignFrom(Simulink.OptimizationCC,true);
        end

    elseif strcmp(event,'update_host_model')

        model=get_param(hObj.getModel,'Name');
        isMulticoreAnalysisActive=(strcmp(get_param(hObj.getModel,'MulticoreDesignerActive'),'on')&&...
        (strcmp(get_param(hObj.getModel,'MulticoreDesignerAction'),'EstimateCost')||...
        strcmp(get_param(hObj.getModel,'MulticoreDesignerAction'),'PartitionTasks')));




        if~isMulticoreAnalysisActive

            isGeneratingNativeThreadsExample=...
            strcmpi(get_param(hObj,'GenerateSampleERTMain'),'on')&&...
            strcmpi(get_param(hObj,'TargetOS'),'NativeThreadsExample');

            if(strcmp(get_param(hObj.getModel,'ModelingArchitecture'),'Deployment')&&...
                strcmp(get_param(hObj.getModel,'ModelReferenceTargetType'),'NONE')&&...
                strcmp(get_param(hObj.getConfigSet(),'SystemTargetFile'),'ert.tlc'))
                if strcmp(get_param(hObj,'MatFileLogging'),'on')&&...
                    strcmp(get_param(hObj.getModel,'ExplicitPartitioning'),'on')
                    DAStudio.error('Simulink:mds:MatFileLoggingNotSupported');
                end


                fcnCtrlProt=get_param(hObj.getModel,'RTWFcnClass');
                if~isempty(fcnCtrlProt)&&~isa(fcnCtrlProt,'RTW.FcnDefault')
                    DAStudio.error('Simulink:mds:FunctionPrototypeControlNotSupported');
                end


                isExtMode=strcmp(get_param(hObj,'ExtMode'),'on');
                isXCPExtMode=isExtMode&&strcmp(get_param(hObj,'ExtModeMexFile'),'ext_xcp');
                isASAP2=strcmp(get_param(hObj,'GenerateASAP2'),'on');
                cs=hObj.getConfigSet();
                isNotCoderTarget=~cs.isValidParam('CoderTargetData');

                if coder.internal.connectivity.featureOn('XcpNativeThreads')
                    isUnsupportedInterface=((isExtMode&&~isXCPExtMode)||isASAP2);
                else
                    isUnsupportedInterface=(isExtMode||isASAP2);
                end
                isDDSApp=~isempty(which('dds.internal.isInstalledAndLicensed'))&&...
                dds.internal.isInstalledAndLicensed('test')&&...
                dds.internal.coder.isDDSApp(hObj.getModel);

                if isUnsupportedInterface&&isNotCoderTarget
                    DAStudio.error('Simulink:mds:DataExchangeInterfaceNotSupported');
                end

                if strcmpi(get_param(cs,'GenCodeOnly'),'off')&&...
                    ~isGeneratingNativeThreadsExample&&...
                    isNotCoderTarget&&~isDDSApp
                    DAStudio.error('Simulink:mds:ErtBuildWithNativeThreadsExample');
                end
            elseif strcmp(get_param(hObj.getModel,'ModelReferenceTargetType'),'NONE')

                if isGeneratingNativeThreadsExample&&...
                    strcmp(get_param(hObj.getConfigSet(),'SystemTargetFile'),'ert.tlc')
                    cs=hObj.getConfigSet();
                    if~(hdlcoderui.isslhdlcinstalled)||isempty(cs.getComponent('HDL Coder'))
                        DAStudio.error('Simulink:mds:cannotGenNativeThreadsExample');
                    elseif~strcmp(get_param(hObj.getModel,'HDLCodeGenStatus'),'Running')
                        DAStudio.error('Simulink:mds:cannotGenNativeThreadsExample');
                    end
                end
            end
        end

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



        if~isempty(hObj.getConfigSet)
            if strcmp(get_param(hObj.getModel,'ModelReferenceTargetType'),'NONE')&&...
                strcmp(get_param(hObj,'GRTInterface'),'on')&&...
                strcmp(get_param(getConfigSet(hObj),'EnableUserReplacementTypes'),'on')
                DAStudio.error('RTW:configSet:cannotGenGRTInterfaceAndDTR');
            end
        end




        cs=getConfigSet(hObj);
        if~isempty(cs)
            if(strcmp(get_param(cs,'PortableWordSizes'),'on')&&...
                strcmp(get_param(cs,'CreateSILPILBlock'),'SIL')&&...
                strcmp(silblocktype,'legacy'))




                assert(strcmp(get_param(cs,'ProdEqTarget'),'on'),...
                'Cannot have PortableWordSizes and Test hardware both enabeld');

                targetCharacteristics=[...
                get_param(cs,'TargetBitPerChar')...
                ,get_param(cs,'TargetBitPerShort')...
                ,get_param(cs,'TargetBitPerInt')...
                ,get_param(cs,'TargetBitPerLong')];

                requiredTypeSizesOnTarget=[8,16,32];
                if~isempty(setdiff(requiredTypeSizesOnTarget,targetCharacteristics))
                    DAStudio.error('PIL:pil:GenerateErtSFunctionIncompatibleHardwareCharacteristics');
                end
            end
        end





        if strcmp(get_param(hObj,'CombineOutputUpdateFcns'),'on')&&...
            strcmp(get_param(hObj,'GRTInterface'),'on')
            throw(MSLException([],message('RTW:configSet:cannotCombineOutputUpdateFcns',model)));
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

        setToolchainInfoCompliance(hObj);

    end


    if ismethod(hObj,'getExtensionUpdate')
        hObj.getExtensionUpdate(event);
    end

    codertarget.updateExtension(hObj,event);




    function setToolchainInfoCompliance(hObj)
        parent=hObj.getParent();
        stf='';
        if~isempty(parent)
            stf=parent.SystemTargetFile;
        end
        if any(strcmpi(stf,{'ert.tlc','ert_shrlib.tlc'}))
            set_param(hObj,'UseToolchainInfoCompliant','on');
        end




