function configSet(obj)













    newRules={};

    if isR2020bOrEarlier(obj.ver)

        activeConfigSet=getActiveConfigSet(obj.modelName);
        if~isa(activeConfigSet,'ConfigSetRef')
            try
                mapping=Simulink.CodeMapping.get(obj.modelName,'CppModelMapping');
                if~isempty(mapping)
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair GenerateExternalIOAccessMethods "'...
                    ,mapping.DefaultsMapping.GenerateExternalInportsAccessMethods,'">'];
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair ExternalIOMemberVisibility "'...
                    ,mapping.DefaultsMapping.ExternalInportsMemberVisibility,'">'];
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair ParameterMemberVisibility "'...
                    ,mapping.DefaultsMapping.ParameterMemberVisibility,'">'];
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair GenerateParameterAccessMethods "'...
                    ,mapping.DefaultsMapping.GenerateParameterAccessMethods,'">'];
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair InternalMemberVisibility "'...
                    ,mapping.DefaultsMapping.InternalMemberVisibility,'">'];
                    newRules{end+1}=['<Object<ClassName|"Simulink.CPPComponent">:insertpair GenerateInternalMemberAccessMethods "'...
                    ,mapping.DefaultsMapping.GenerateInternalMemberAccessMethods,'">'];
                end
            catch %#ok<CTCH>

            end
        end
    end



    if isR2019aOrEarlier(obj.ver)

        newRules{end+1}='<EfficientTunableParamExpr:remove>';
    end

    if isR2018bOrEarlier(obj.ver)

        newRules{end+1}='<Simulink.ConfigSetRef<SourceName:rename WSVarName>>';
        newRules{end+1}='<DenormalBehavior:remove>';
    end

    if isR2018aOrEarlier(obj.ver)

        newRules{end+1}='<WILDCARD<PurelyIntegerCode:remove><SupportContinuousTime:insertsib>>';

        newRules{end+1}='<UnderSpecifiedDimensionMsg:remove>';
    end

    if isR2017bOrEarlier(obj.ver)

        newRules{end+1}='<StringTruncationChecking:remove>';
        newRules{end+1}='<DynamicStringBufferSize:remove>';
    end

    if isR2016bOrEarlier(obj.ver)









        newRules{end+1}='<WILDCARD<TargetLibSuffix><MultiwordTypeDef:rename ERTMultiwordTypeDef>>';
        newRules{end+1}='<WILDCARD<TargetLibSuffix><IsERTTarget|on><MultiwordLength:rename ERTMultiwordLength>>';
    end

    if isR2016aOrEarlier(obj.ver)



        newRules{end+1}='<UserDataClassName:remove>';
        newRules{end+1}='<CSCSource:remove>';
    end




    if isRelease(obj.ver,'R2020b')


        simHardwareAcceleration=get_param(obj.origModelName,'SimHardwareAcceleration');

        if strcmpi(simHardwareAcceleration,'off')
            newRules{end+1}='<SimulationSettings:insertpair SimSIMDOptimization "Off">';
        end
    end

    if isR2020aOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)


            CS=getConfigSet(obj.modelName,sets{i});
            if~isa(CS,'Simulink.ConfigSetRef')
                val=CS.get_param('SolverName');
                newRules{end+1}=['<Simulink.SolverCC:insertpair Solver ',val,'>'];%#ok<AGROW>
            end
        end
    end

    if isR2006bOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CSorCSR=getConfigSet(obj.modelName,sets{i});
            if isa(CSorCSR,'Simulink.ConfigSetRef')
                real_cs=CSorCSR.getRefConfigSet;
                real_cs_copy=copy(real_cs);
                locSetHWDeviceTypes(real_cs_copy);
                locSetTargetLang(real_cs_copy,obj.ver);
                attachConfigSet(obj.modelName,real_cs_copy,true);
                if(CSorCSR.isActive)
                    setActiveConfigSet(obj.modelName,real_cs_copy.Name);
                end
                detachConfigSet(obj.modelName,CSorCSR.Name);
                set_param(real_cs_copy,'Name',CSorCSR.Name);
            else
                locSetHWDeviceTypes(CSorCSR);
                locSetTargetLang(CSorCSR,obj.ver);
            end
        end
        if isR2006a(obj.ver)
            handledTargets={};
            for i=1:length(sets)
                CS=getConfigSet(obj.modelName,sets{i});
                isCompliant=CS.getComponent('Code Generation').getComponent('Target').ERTFirstTimeCompliant;
                if(strcmp(isCompliant,'off'))
                    CS.getComponent('Code Generation').IncludeERTFirstTime='off';
                else
                    targetName=CS.getComponent('Code Generation').getComponent('Target').class;
                    if~any(strcmp(targetName,handledTargets))
                        newRules{end+1}=['<Simulink.RTWCC<Array<',targetName...
                        ,'>><IncludeERTFirstTime:remove><Array<',targetName,':insert>>>'];%#ok<AGROW>
                        handledTargets{end+1}=targetName;%#ok<AGROW>
                    end
                end
            end
        end
    end

    if isR2007a(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});
            if~isa(CS,'Simulink.ConfigSetRef')
                locSetHWDeviceTypes(CS);
                locSetTargetLang(CS,obj.ver);
            end
        end
    end

    if isR2007b(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});
            if~isa(CS,'Simulink.ConfigSetRef')
                locSetTargetLang(CS,obj.ver);
            end
        end
    end

    if isR2010aOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});
            if~isa(CS,'Simulink.ConfigSetRef')
                if isequal(get_param(CS,'IsERTTarget'),'off')
                    set_param(CS,'MatFileLogging','on');
                    set_param(CS,'SupportNonFinite','on');
                    CS.getComponent('Code Generation').getComponent('Target').setPropEnabled('SupportNonFinite','off');
                end
            end
        end
    end

    if isR2011aOrEarlier(obj.ver)
        newRules{end+1}='<Simulink.DebuggingCC<FrameProcessingCompatibilityMsg:remove>>';
    end

    if isR2013aOrEarlier(obj.ver)
        newRules{end+1}='<Simulink.ERTTargetCC<IndentStyle:remove>>';
        newRules{end+1}='<Simulink.ERTTargetCC<IndentSize:remove>>';
    end

    if isR2013bOrEarlier(obj.ver)
        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});
            if~isa(CS,'Simulink.ConfigSetRef')
                locSetTargetLang(CS,obj.ver);
            end
        end
        newRules{end+1}='<Simulink.CodeAppCC<CommentStyle:remove>>';
        newRules{end+1}='<Simulink.GRTTargetCC<MultiInstanceErrorCode:remove>>';
        newRules{end+1}='<pjtgeneratorpkg.GRTFactory<MultiInstanceErrorCode:remove>>';
        newRules{end+1}='<tlmg.TLMGRTTargetCC<MultiInstanceErrorCode:remove>>';



        newRules{end+1}='<WILDCARD<TargetLangStandard|"C89/C90 (ANSI)"><CodeReplacementLibrary|"Intel IPP":repval "Intel IPP (ANSI)">>';
        newRules{end+1}='<WILDCARD<TargetLangStandard|"C99 (ISO)"><CodeReplacementLibrary|"Intel IPP":repval "Intel IPP (ISO)">>';
        newRules{end+1}='<WILDCARD<TargetLangStandard|"C++03 (ISO)"><CodeReplacementLibrary|"Intel IPP":repval "Intel IPP (ISO)">>';

        newRules{end+1}='<TargetLangStandard:remove>';

        newRules{end+1}='0<GenFloatMathFcnCalls:remove>';



        newRules{end+1}='0<Simulink.CPPComponent:rename Simulink.ERTCPPComponent>';






        newRules{end+1}='<Simulink.RTWCC<TargetLang|"C++":repval "C++ (Encapsulated)"><Array<WILDCARD<CPPClassGenCompliant|on><CodeInterfacePackaging|"C++ class">>>>';




        newRules{end+1}='<Simulink.RTWCC<TargetLang|"C++"><Array<WILDCARD<CPPClassGenCompliant|off><Array<Simulink.ERTCPPComponent:remove>>>>>';

        newRules{end+1}='<CodeInterfacePackaging:remove>';
    end

    if isR2014aOrEarlier(obj.ver)

        sets=getConfigSets(obj.modelName);
        for i=1:length(sets)
            CS=getConfigSet(obj.modelName,sets{i});
            locTurnOnCombineOutputUpdateFcns(CS);
        end
    end

    obj.appendRules(newRules);








    function locTurnOnCombineOutputUpdateFcns(configSet)
        if isa(configSet,'Simulink.ConfigSetRef')
            if strcmp(configSet.SourceResolved,'off')
                return;
            else
                configSet=configSet.getRefConfigSet;
            end
        end
        if isequal(get_param(configSet,'IsERTTarget'),'off')
            targetComp=configSet.getComponent('Code Generation').getComponent('Target');
            if isequal(get_param(configSet,'GRTInterface'),'off')


                targetComp.setPropEnabled('CombineOutputUpdateFcns','on');
                set_param(configSet,'CombineOutputUpdateFcns','on');
            end
            targetComp.setPropEnabled('CombineOutputUpdateFcns','off');
        end





        function locSetHWDeviceTypes(configSet)

            hwCC=configSet.getComponent('Hardware Implementation');



            OptionsPre7b={'16-bit Generic',...
            '32-bit Embedded Processor',...
            '32-bit Generic',...
            '32-bit Generic Real Time Simulator',...
            '32-bit Real-Time Windows Target',...
            '32-bit xPC Target (AMD Athlon)',...
            '32-bit xPC Target (Intel Pentium)',...
            '8-bit Generic',...
            '8051 Compatible',...
            'ADI Blackfin',...
            'ADI SHARC',...
            'ARM7',...
            'ASIC/FPGA',...
            'Freescale DSP563xx 16-bit',...
            'Freescale MPC5500',...
            'Hitachi SH-2',...
            'Infineon C16x',...
            'Infineon TriCore',...
            'MATLAB Host',...
            'Motorola 68332',...
            'Motorola 68HC11',...
            'Motorola HC08',...
            'Motorola HC12',...
            'Motorola PowerPC',...
            'NEC 85x',...
            'Renesas M16C',...
            'SGI UltraSPARC IIi',...
            'ST Microelectronics ST10',...
            'Specified',...
            'TI C2000',...
            'TI C5000',...
            'TI C6000'};

            curProdType=get_param(configSet,'ProdHWDeviceType');
            curProdBitPerChar=get_param(configSet,'ProdBitPerChar');
            curProdBitPerInt=get_param(configSet,'ProdBitPerInt');
            curProdBitPerLong=get_param(configSet,'ProdBitPerLong');
            curProdBitPerShort=get_param(configSet,'ProdBitPerShort');
            curProdBitPerFloat=get_param(configSet,'ProdBitPerFloat');
            curProdBitPerDouble=get_param(configSet,'ProdBitPerDouble');
            curProdBitPerPointer=get_param(configSet,'ProdBitPerPointer');
            curProdBitPerSizeT=get_param(configSet,'ProdBitPerSizeT');
            curProdBitPerPtrDiffT=get_param(configSet,'ProdBitPerPtrDiffT');
            curProdEndianess=get_param(configSet,'ProdEndianess');
            curProdIntDivRoundTo=get_param(configSet,'ProdIntDivRoundTo');
            curProdShiftRightIntArith=get_param(configSet,'ProdShiftRightIntArith');
            curProdWordSize=get_param(configSet,'ProdWordSize');
            curProdLargestAtomicInteger=get_param(configSet,'ProdLargestAtomicInteger');
            curProdLargestAtomicFloat=get_param(configSet,'ProdLargestAtomicFloat');


            curTgtType=get_param(configSet,'TargetHWDeviceType');
            noTgtConfig=false;
            try

                curTgtBitPerChar=get_param(configSet,'TargetBitPerChar');
                curTgtBitPerInt=get_param(configSet,'TargetBitPerInt');
                curTgtBitPerLong=get_param(configSet,'TargetBitPerLong');
                curTgtBitPerShort=get_param(configSet,'TargetBitPerShort');
                curTgtBitPerFloat=get_param(configSet,'TargetBitPerFloat');
                curTgtBitPerDouble=get_param(configSet,'TargetBitPerDouble');
                curTgtBitPerPointer=get_param(configSet,'TargetBitPerPointer');
                curTgtBitPerSizeT=get_param(configSet,'TargetBitPerSizeT');
                curTgtBitPerPtrDiffT=get_param(configSet,'TargetBitPerPtrDiffT');
                curTgtEndianess=get_param(configSet,'TargetEndianess');
                curTgtIntDivRoundTo=get_param(configSet,'TargetIntDivRoundTo');
                curTgtShiftRightIntArith=get_param(configSet,'TargetShiftRightIntArith');
                curTgtWordSize=get_param(configSet,'TargetWordSize');
                curTgtLargestAtomicInteger=get_param(configSet,'TargetLargestAtomicInteger');
                curTgtLargestAtomicFloat=get_param(configSet,'TargetLargestAtomicFloat');
            catch %#ok<CTCH>

                noTgtConfig=true;
            end

            ProdEqTgtFlag=get_param(configSet,'ProdEqTarget');

            try
                hh=targetrepository.getHardwareImplementationHelper();




                aliases=hh.getDevice(curProdType).AliasList;

                if aliases.Size>0
                    aliasMatch=intersect(aliases.toArray(),OptionsPre7b);
                else
                    aliasMatch={};
                end

                if~isempty(aliasMatch)
                    pre7bProdType=aliasMatch{1};
                else
                    pre7bProdType='Specified';
                end

                set_param(configSet,'ProdHWDeviceType',pre7bProdType);

                set(hwCC,'ProdBitPerChar',curProdBitPerChar);
                set(hwCC,'ProdBitPerInt',curProdBitPerInt);
                set(hwCC,'ProdBitPerLong',curProdBitPerLong);
                set(hwCC,'ProdBitPerShort',curProdBitPerShort);
                set(hwCC,'ProdBitPerFloat',curProdBitPerFloat);
                set(hwCC,'ProdBitPerDouble',curProdBitPerDouble);
                set(hwCC,'ProdBitPerPointer',curProdBitPerPointer);
                set(hwCC,'ProdBitPerSizeT',curProdBitPerSizeT);
                set(hwCC,'ProdBitPerPtrDiffT',curProdBitPerPtrDiffT);
                set(hwCC,'ProdEndianess',curProdEndianess);
                set(hwCC,'ProdIntDivRoundTo',curProdIntDivRoundTo);
                set(hwCC,'ProdShiftRightIntArith',curProdShiftRightIntArith);
                set(hwCC,'ProdWordSize',curProdWordSize);
                set(hwCC,'ProdLargestAtomicInteger',curProdLargestAtomicInteger);
                set(hwCC,'ProdLargestAtomicFloat',curProdLargestAtomicFloat);

                if~noTgtConfig
                    aliases=hh.getDevice(curTgtType).AliasList;

                    if aliases.Size>0
                        aliasMatch=intersect(aliases.toArray(),OptionsPre7b);
                    else
                        aliasMatch={};
                    end

                    if~isempty(aliasMatch)
                        pre7bTgtType=aliasMatch{1};
                    else
                        pre7bTgtType='Specified';
                    end

                    set_param(configSet,'TargetHWDeviceType',pre7bTgtType);

                    set(hwCC,'TargetBitPerChar',curTgtBitPerChar);
                    set(hwCC,'TargetBitPerInt',curTgtBitPerInt);
                    set(hwCC,'TargetBitPerLong',curTgtBitPerLong);
                    set(hwCC,'TargetBitPerShort',curTgtBitPerShort);
                    set(hwCC,'TargetBitPerFloat',curTgtBitPerFloat);
                    set(hwCC,'TargetBitPerDouble',curTgtBitPerDouble);
                    set(hwCC,'TargetBitPerPointer',curTgtBitPerPointer);
                    set(hwCC,'TargetBitPerSizeT',curTgtBitPerSizeT);
                    set(hwCC,'TargetBitPerPtrDiffT',curTgtBitPerPtrDiffT);
                    set(hwCC,'TargetEndianess',curTgtEndianess);
                    set(hwCC,'TargetIntDivRoundTo',curTgtIntDivRoundTo);
                    set(hwCC,'TargetShiftRightIntArith',curTgtShiftRightIntArith);
                    set(hwCC,'TargetWordSize',curTgtWordSize);
                    set(hwCC,'TargetLargestAtomicInteger',curTgtLargestAtomicInteger);
                    set(hwCC,'TargetLargestAtomicFloat',curTgtLargestAtomicFloat);
                end

                set_param(configSet,'ProdEqTarget',ProdEqTgtFlag);
            catch %#ok<CTCH>


                try
                    set_param(configSet,'ProdHWDeviceType','Specified');
                    set_param(configSet,'TargetHWDeviceType','Specified');
                    set_param(configSet,'ProdEqTarget',ProdEqTgtFlag);
                catch %#ok<CTCH>


                end
            end






            function locSetTargetLang(configSet,saveAsVersionObj)




                currentLang=get_param(configSet,'TargetLang');

                if isR2013bOrEarlier(saveAsVersionObj)
                    if strcmpi(get_param(configSet,'IsERTTarget'),'on')
                        if strcmpi(get_param(configSet,'CodeInterfacePackaging'),'C++ class')
                            currentLang='C++ (Encapsulated)';
                            set_param(configSet,'IgnoreCustomStorageClasses','On');
                            set_param(configSet,'MultiInstanceErrorCode','Error');
                            set_param(configSet,'GenerateSampleERTMain','On');
                        end
                    elseif configSet.hasProp('CPPClassGenCompliant')&&strcmpi(get_param(configSet,'CPPClassGenCompliant'),'on')
                        cacheEnabledState=configSet.getPropEnabled('CPPClassGenCompliant');
                        if~cacheEnabledState
                            configSet.setPropEnabled('CPPClassGenCompliant','On');
                        end
                        set_param(configSet,'CPPClassGenCompliant','Off');
                        if~cacheEnabledState
                            configSet.setPropEnabled('CPPClassGenCompliant','Off');
                        end
                    end
                end

                if isR2007bOrEarlier(saveAsVersionObj)

                    if strcmp(currentLang,'C++ (Encapsulated)')
                        set_param(configSet,'TargetLang','C');
                    end
                end




