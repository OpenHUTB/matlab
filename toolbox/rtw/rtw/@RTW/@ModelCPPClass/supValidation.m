function[status,msg]=supValidation(hSrc)




















    status=1;
    msg='';

    hModel=hSrc.ModelHandle;
    if~ishandle(hModel)
        status=0;
        msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
        return;
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                status=0;
                msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
                return;
            end
        catch theMe
            status=0;
            msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
            return;
        end
    end

    fullname=getfullname(hModel);


    modelArgsAsStructRef=false;
    if hSrc.RightClickBuild
        cs=getActiveConfigSet(bdroot(hSrc.SubsysBlockHdl));
        [isMapped,mapping]=Simulink.CodeMapping.isMappedToCppERTSwComponent(bdroot(hSrc.SubsysBlockHdl));
        if isMapped
            defaultMapping=mapping.DefaultsMapping;
            modelArgsAsStructRef=~strcmpi(defaultMapping.ModelParameterArgumentsVisibility,'None')&&...
            strcmpi(defaultMapping.getDataProperty('ModelParameterArguments'),'StructureReference');
        end
    else
        cs=getActiveConfigSet(hModel);
        [isMapped,mapping]=Simulink.CodeMapping.isMappedToCppERTSwComponent(hModel);
        if isMapped
            defaultMapping=mapping.DefaultsMapping;
            modelArgsAsStructRef=~strcmpi(defaultMapping.ModelParameterArgumentsVisibility,'None')&&...
            strcmpi(defaultMapping.getDataProperty('ModelParameterArguments'),'StructureReference');
        end
    end

    try
        isERTTarget=strcmpi(get_param(cs,'IsERTTarget'),'on');

        if~strncmpi(get_param(cs,'TargetLang'),'C++',3)
            msg=DAStudio.message('RTW:fcnClass:targetLangCpp');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        tlcOptions=get_param(fullname,'TLCOptions');
        isExportFcn=~isempty(strfind(tlcOptions,'ExportFunctionsMode=1'));%#ok

        if isExportFcn
            msg=DAStudio.message('RTW:fcnClass:cppExpFcnNotSupported');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end



        isCompliant=get_param(cs,'CPPClassGenCompliant');
        if~strcmp(isCompliant,'on')
            msg=DAStudio.message('RTW:configSet:nonCPPClassGenCompliant');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        gentestinterface=get_param(cs,'GenerateTestInterfaces');
        if strcmp(gentestinterface,'on')
            msg=DAStudio.message('RTW:fcnClass:cppConfigSetOff','GenerateTestInterfaces');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if strcmp(get_param(cs,'MultiInstanceERTCode'),'off')
            msg=DAStudio.message('RTW:fcnClass:cppConfigSetOn','MultiInstanceERTCode');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'SolverType'),'Variable-step')&&...
            ~(hSrc.RightClickBuild)
            msg=DAStudio.message('RTW:fcnClass:cppVariableStepType');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'GenerateAllocFcn'),'on')
            msg=DAStudio.message('RTW:fcnClass:CPPClassMalloc');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'GRTInterface'),'on')
            msg=DAStudio.message('RTW:fcnClass:cppConfigSetOff','GRTInterface');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'GenerateASAP2'),'on')
            msg=DAStudio.message('RTW:fcnClass:cppConfigSetOff','GenerateASAP2');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif isERTTarget&&~strcmpi(get_param(cs,'RootIOFormat'),'structure reference')
            msg=DAStudio.message('RTW:fcnClass:cppRootIOFormat');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif isERTTarget&&~strcmp(get_param(cs,'RateGroupingCode'),'on')
            msg=DAStudio.message('RTW:fcnClass:cppRateGroupingCode');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif((~strcmp(get_param(cs,'ExternalIOMemberVisibility'),'public'))&&...
            strcmp(get_param(cs,'GenerateExternalIOAccessMethods'),'None'))
            msg=DAStudio.message('coderdictionary:mapping:InaccessibleCppPrivateIO');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'CreateSILPILBlock'),'SIL')&&...
            strcmp(silblocktype,'legacy')&&...
            ~strcmp(get_param(cs,'ParameterMemberVisibility'),'public')&&...
            strcmp(get_param(cs,'GenerateParameterAccessMethods'),'None')
            msg=DAStudio.message('coderdictionary:mapping:InaccessibleCppPrivateSILModelParams');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'CreateSILPILBlock'),'SIL')&&...
            strcmp(silblocktype,'legacy')&&...
            ~strcmp(get_param(cs,'InternalMemberVisibility'),'public')&&...
            strcmp(get_param(cs,'GenerateInternalMemberAccessMethods'),'None')
            msg=DAStudio.message('RTW:fcnClass:cppPrivInternalMemNoAccessMethods');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'UseOperatorNewForModelRefRegistration'),'on')&&...
            strcmp(get_param(cs,'GenerateDestructor'),'off')
            msg=DAStudio.message('RTW:fcnClass:cppDynMemDestructor');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif isERTTarget&&strcmp(get_param(cs,'RateTransitionBlockCode'),'Function')
            msg=DAStudio.message('RTW:fcnClass:cppInlinedRtbCode');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif slfeature('RTWCGStdArraySupport')&&isERTTarget&&...
            ~strcmp(get_param(cs,'ArrayContainerType'),'C-style array')&&...
            (strcmp(get_param(cs,'ZeroInternalMemoryAtStartup'),'on')||...
            strcmp(get_param(cs,'ZeroExternalMemoryAtStartup'),'on'))
            msg=DAStudio.message('RTW:fcnClass:cppStdContainerZeroInit');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if strcmp(hSrc.FunctionName,fullname)

            msg=DAStudio.message('RTW:fcnClass:cppFcnNameConflictsMdlName',...
            hSrc.FunctionName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if strcmpi(get_param(hModel,'ModelReferenceTargetType'),'none')&&...
            isValidParam(cs,'GenerateSampleERTMain')&&...
            strcmpi(get_param(cs,'GenerateSampleERTMain'),'off')&&...
            strcmpi(get_param(cs,'CreateSILPILBlock'),'None')&&...
            strcmpi(get_param(cs,'GenCodeOnly'),'off')
            if modelArgsAsStructRef
                msg=DAStudio.message('RTW:fcnClass:GenerateSampleERTMainConstraintCppInstP');
                DAStudio.error('RTW:fcnClass:finish',msg);
            end
        end
        if strcmp(hSrc.FunctionName,hSrc.ModelClassName)

            msg=DAStudio.message('RTW:fcnClass:cppFcnNameConflictsClsName',...
            hSrc.FunctionName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(fullname);

        if(strcmpi(mappingType,'CppModelMapping'))
            return;
        end


        dummyConfigEntry=RTW.CPPFcnArgSpec;
        dummyConfigEntry.ArgName=hSrc.FunctionName;

        if~dummyConfigEntry.isValidCPPIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidFunctionName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if~dummyConfigEntry.isValidRTWIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWFunctionName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        dummyConfigEntry=RTW.CPPFcnArgSpec;
        dummyConfigEntry.ArgName=hSrc.ModelClassName;

        if~dummyConfigEntry.isValidCPPIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidClassName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if~dummyConfigEntry.isValidRTWIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWClassName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        dummyConfigEntry=RTW.CPPFcnArgSpec;
        dummyConfigEntry.ArgName=hSrc.ClassNamespace;

        if~dummyConfigEntry.isValidCPPIdentifier()&&~isempty(hSrc.ClassNamespace)
            msg=DAStudio.message('RTW:fcnClass:cppNotValidNamespaceName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if~dummyConfigEntry.isValidRTWIdentifier()&&~isempty(hSrc.ClassNamespace)
            msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWNamespaceName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if strcmp(hSrc.ClassNamespace,fullname)
            msg=DAStudio.message('RTW:fcnClass:cppNamespaceEqModelName');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end
    catch me %#ok
        status=0;
    end


