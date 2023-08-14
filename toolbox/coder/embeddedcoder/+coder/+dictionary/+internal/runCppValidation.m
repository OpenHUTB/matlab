function[status,msg]=runCppValidation(hModel,varargin)





    status=true;
    msg='';


    accessProperty='MemberAccessMethod';
    visibilityProperty='DataVisibility';

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok


    if nargin==2
        callMode=varargin{1};
    else
        callMode='interactive';
    end


    if~ishandle(hModel)
        status=false;
        msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
        return;
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                status=false;
                msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
                return;
            end
        catch theMe %#ok
            status=false;
            msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
            return;
        end
    end

    nameToReport=getfullname(hModel);
    cm=coder.mapping.api.get(nameToReport);

    cs=getActiveConfigSet(hModel);

    compileObj=coder.internal.CompileModel;

    try
        isERTTarget=strcmpi(get_param(cs,'IsERTTarget'),'on');

        if~strncmpi(get_param(cs,'TargetLang'),'C++',3)
            msg=DAStudio.message('RTW:fcnClass:targetLangCpp');
            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        tlcOptions=get_param(nameToReport,'TLCOptions');
        isExportFcn=contains(tlcOptions,'ExportFunctionsMode=1');

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
        elseif((~strcmp(cm.getData('Inports',visibilityProperty),'public'))&&...
            strcmp(cm.getData('Inports',accessProperty),'None'))
            msg=DAStudio.message('coderdictionary:mapping:InaccessibleCppPrivateIO');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif((~strcmp(cm.getData('Outports',visibilityProperty),'public'))&&...
            strcmp(cm.getData('Outports',accessProperty),'None'))
            msg=DAStudio.message('coderdictionary:mapping:InaccessibleCppPrivateIO');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'CreateSILPILBlock'),'SIL')&&...
            strcmp(silblocktype,'legacy')&&...
            ~strcmp(cm.getData('ModelParameters',visibilityProperty),'public')&&...
            strcmp(cm.getData('ModelParameters',accessProperty),'None')
            msg=DAStudio.message('coderdictionary:mapping:InaccessibleCppPrivateSILModelParams');
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(get_param(cs,'CreateSILPILBlock'),'SIL')&&...
            strcmp(silblocktype,'legacy')&&...
            ~strcmp(cm.getData('Internal',visibilityProperty),'public')&&...
            strcmp(cm.getData('Internal',accessProperty),'None')
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

        modelClassName=cm.getClassName();

        dummyConfigEntry=RTW.CPPFcnArgSpec;
        dummyConfigEntry.ArgName=modelClassName;

        if~isempty(modelClassName)&&...
            ~dummyConfigEntry.isValidCPPIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidClassName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if~isempty(modelClassName)&&...
            ~dummyConfigEntry.isValidRTWIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWClassName',...
            dummyConfigEntry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        dummyConfigEntry=RTW.CPPFcnArgSpec;
        modelClassNamespace=cm.getClassNamespace();

        if~isempty(modelClassNamespace)
            nestedNamespaces=split(string(modelClassNamespace),'::');

            for idx=1:length(nestedNamespaces)
                namespace=nestedNamespaces(idx);

                if isempty(namespace)||strcmp(namespace,"")
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidNamespaceName',...
                    namespace);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end

                dummyConfigEntry.ArgName=namespace;
                if~dummyConfigEntry.isValidCPPIdentifier()
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidNamespaceName',...
                    dummyConfigEntry.ArgName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end

                if~dummyConfigEntry.isValidRTWIdentifier()
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWNamespaceName',...
                    dummyConfigEntry.ArgName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end

                if strcmp(namespace,nameToReport)
                    msg=DAStudio.message('RTW:fcnClass:cppNamespaceEqModelName');
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end
        end



        simStatus=get_param(hModel,'SimulationStatus');
        if~strcmpi(simStatus,'paused')&&...
            ~strcmpi(simStatus,'initializing')&&...
            ~strcmpi(simStatus,'running')&&...
            ~strcmpi(simStatus,'updating')

            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                DAStudio.error('RTW:fcnClass:accelSimForbiddenForCPP')
            end
            try
                lastwarn('');
                compileObj.compile(hModel);
                if~isempty(lastwarn)
                    disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
                end
            catch ex
                for i=1:length(ex.cause)
                    stageName=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceFor',nameToReport).getString;
                    myStage=Simulink.output.Stage(stageName,'ModelName',get_param(hModel,'name'),...
                    'UIMode',true);
                    cleanupState=onCleanup(@()delete(myStage));
                    Simulink.output.error(ex.cause{i});
                end
                if length(ex.cause)==1
                    msg=ex.cause.message;
                else
                    msg=ex.cause{1}.message;
                end
                loc_throwError(message('RTW:fcnClass:modelNotCompile',msg));
            end
        end
        [mapping,~]=Simulink.CodeMapping.getCurrentMapping(hModel);
        if~isempty(mapping)
            for i=1:length(mapping.OutputFunctionMappings)
                if length(mapping.OutputFunctionMappings)==1
                    mappingObj=mapping.OutputFunctionMappings;
                else
                    mappingObj=mapping.OutputFunctionMappings(i);
                end
                pfmNotExpanded=mappingObj.Prototype;
                if contains(pfmNotExpanded,'$M')
                    continue
                end

                periodicFunctionName=Simulink.CodeMapping.getResolvedFunctionName(mappingObj,...
                hModel,'OutputFunctionMappings');
                if strcmp(periodicFunctionName,nameToReport)

                    msg=DAStudio.message('RTW:fcnClass:cppFcnNameConflictsMdlName',...
                    periodicFunctionName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end

                if~isempty(modelClassName)
                    if strcmp(periodicFunctionName,modelClassName)

                        msg=DAStudio.message('RTW:fcnClass:cppFcnNameConflictsClsName',...
                        periodicFunctionName);
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end
                end

                dummyConfigEntry=RTW.CPPFcnArgSpec;
                dummyConfigEntry.ArgName=periodicFunctionName;

                if~isempty(periodicFunctionName)&&...
                    ~dummyConfigEntry.isValidCPPIdentifier()
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidFunctionName',...
                    dummyConfigEntry.ArgName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end


                if~isempty(periodicFunctionName)&&...
                    ~dummyConfigEntry.isValidRTWIdentifier()
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidRTWFunctionName',...
                    dummyConfigEntry.ArgName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end
        end

        isExportFcnDiagram=...
        strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
        slprivate('getIsExportFcnModel',hModel);




        prototype='';
        if length(mapping.OutputFunctionMappings)>=1
            prototype=mapping.OutputFunctionMappings(1).Prototype;
        end
        isFunctionPrototype=contains(prototype,{'(',')'});
        try
            if isFunctionPrototype
                func=coder.parser.Parser.doit(prototype);
            else
                func=[];
            end
        catch
            loc_throwError(message('coderdictionary:mapping:InvalidPrototype',prototype));
        end
        isTopModelCGType=strcmp(get_param(hModel,'ModelReferenceTargetType'),'NONE');
        loc_staticMainIncompatibilities(hModel,cs,isTopModelCGType,cm);

        if loc_usesFPC(func)

            if(strcmpi(callMode,'interactive')||strcmpi(callMode,'finalValidation'))
                if(~isExportFcnDiagram)

                    uddobj=get_param(nameToReport,'UDDObject');
                    singleRate=uddobj.outputFcnHasSinglePeriodicRate();

                    if~singleRate&&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')
                        msg=DAStudio.message('RTW:fcnClass:cppSingleTasking');
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end
                end
            end
            if isExportFcnDiagram
                DAStudio.error('RTW:fcnClass:ioArgsExportFunctionModel');
            end

            if strcmp(get_param(cs,'CombineOutputUpdateFcns'),'off')
                msg=DAStudio.message('RTW:fcnClass:combineOutputUpdate',nameToReport);
                DAStudio.error('RTW:fcnClass:finish',msg);
            end
            if strcmpi(get_param(cs,'IsERTTarget'),'on')&&~strcmp(get_param(cs,'ZeroExternalMemoryAtStartup'),'off')
                msg=DAStudio.message('RTW:fcnClass:cppNonvoidvoidExternalIOInit');
                DAStudio.error('RTW:fcnClass:finish',msg);
            end

            doesPortHaveAccessMethod=@(port)~strcmp(cm.getData(port,accessProperty),'None');
            eitherPortHasAccessMethod=any(cellfun(doesPortHaveAccessMethod,{'Inports','Outports'}));


            if isTopModelCGType&&eitherPortHasAccessMethod
                msg=DAStudio.message('coderdictionary:mapping:CppIOAccessNotNoneWithFPCConfigured');
                DAStudio.error('RTW:fcnClass:finish',msg);
            end

            rtwCppFcnClass=get_param(hModel,'RTWCppFcnClass');
            configData=rtwCppFcnClass.ArgSpecData;
            allFunctionIds=cm.find('PeriodicFunctions');
            if isscalar(allFunctionIds)
                functionId=allFunctionIds;
            else
                functionId=allFunctionIds{1};
            end
            pfmNotExpanded=cm.getFunction(functionId,'MethodName');
            periodicFunctionName=pfmNotExpanded;
            if isscalar(mapping.OutputFunctionMappings)
                outputMappingObj=mapping.OutputFunctionMappings;
            else
                outputMappingObj=mapping.OutputFunctionMappings(1);
            end
            if~contains(pfmNotExpanded,'$M')
                periodicFunctionName=Simulink.CodeMapping.getResolvedFunctionName(outputMappingObj,...
                hModel,'OutputFunctionMappings');
            end

            if(strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))
                loc_syncConfigWithModelForInit(hModel,configData,...
                periodicFunctionName);
            end



            if~isExportFcnDiagram
                fcnCallRootInport=sl('findFcnCallRootInport',hModel);
                if~isempty(fcnCallRootInport)
                    msg=DAStudio.message('RTW:fcnClass:fcnCallRootInport',...
                    getfullname(fcnCallRootInport(1)));
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end


            loc_checkBEPAtRoot(hModel,'Inport');
            loc_checkBEPAtRoot(hModel,'Outport');

            if(strcmpi(callMode,'interactive')||strcmpi(callMode,'finalValidation'))
                [inpH,outpH]=coder.mapping.internal.StepFunctionMapping.getPortHandles(hModel);
                previousDim=[];
                for i=1:length(configData)
                    if isscalar(configData)
                        entry=configData;
                    else
                        entry=configData(i);
                    end

                    [csc,dimensions,dimsMode]=coder.dictionary.internal.getPortProperties(entry,inpH,outpH);

                    [foundCombinedOne,combinedRow,~,~]=...
                    coder.dictionary.internal.foundCombinedIO(entry.Position-1,configData,entry.ArgName);

                    if foundCombinedOne
                        if~strcmp(entry.Category,configData(combinedRow+1).Category)
                            msg=DAStudio.message('RTW:fcnClass:combinedIOCategoryMismatch',entry.ArgName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end
                        if strcmp(entry.Category,'Value')
                            msg=DAStudio.message('RTW:fcnClass:noValueForCombinedIO',entry.SLObjectName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end
                        if~isempty(strfind(entry.Qualifier,'const'))
                            msg=DAStudio.message('RTW:fcnClass:noConstForCombinedIO',entry.SLObjectName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end

                        mdlName=get_param(hModel,'Name');
                        bName1=[mdlName,'/',entry.SLObjectName];
                        bName2=[mdlName,'/',configData(combinedRow+1).SLObjectName];

                        tmp=get_param(bName1,'CompiledPortDataTypes');
                        if strcmp(entry.SLObjectType,'Outport')
                            pType1=tmp.Inport;
                        else
                            pType1=tmp.Outport;
                        end

                        tmp=get_param(bName2,'CompiledPortDataTypes');
                        if strcmp(configData(combinedRow+1).SLObjectType,'Outport')
                            pType2=tmp.Inport;
                        else
                            pType2=tmp.Outport;
                        end

                        if~strcmp(pType1,pType2)
                            msg=DAStudio.message('RTW:fcnClass:combinedIODataTypeMismatch',entry.ArgName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end

                        if~isempty(previousDim)
                            previousDimTotalSize=1;
                            for index=1:length(previousDim)
                                previousDimTotalSize=previousDimTotalSize*previousDim(index);
                            end
                            dimTotalSize=1;
                            for index=1:length(dimensions)
                                dimTotalSize=dimTotalSize*dimensions(index);
                            end
                            if dimTotalSize~=previousDimTotalSize
                                msg=DAStudio.message('RTW:fcnClass:combinedIODataTypeMismatch',...
                                entry.ArgName);
                                DAStudio.error('RTW:fcnClass:finish',msg);
                            end


                            previousDim=[];
                        else


                            previousDim=dimensions;
                        end
                    end

                    if~isempty(csc)&&~strcmp(csc,'Auto')
                        msg=DAStudio.message('RTW:fcnClass:cppGlobalStorageClass',...
                        entry.SLObjectName);
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end


                    if any(dimsMode)
                        msg=DAStudio.message('RTW:fcnClass:cppVariableSizeSignal',...
                        entry.SLObjectName);
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end


                    for index=1:length(dimensions)
                        if dimensions(index)>1&&...
                            strcmp(entry.Category,'Value')
                            msg=DAStudio.message('RTW:fcnClass:portValue',...
                            entry.SLObjectName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end
                        if dimensions(index)>1&&...
                            strcmp(entry.Category,'Reference')&&...
                            (strcmp(get_param(hModel,'ArrayContainerType'),'std::array')||...
                            strcmp(get_param(hModel,'ArrayContainerType'),'std::vector')||...
                            (slfeature('RTWCGStdArraySupport')>0&&slsvTestingHook('RTWCGStdVectorForSMT')>0))
                            msg=DAStudio.message('RTW:fcnClass:portReference',...
                            entry.SLObjectName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end
                    end



                    portIdx=entry.PortNum+1;
                    isInport=strcmp(entry.SLObjectType,'Inport');
                    dtTable=Simulink.internal.DataTypeTable(nameToReport);
                    portType=[];
                    if isInport
                        res=get_param(inpH(portIdx),'CompiledPortDataTypes');
                        if~isempty(res.Outport)
                            portType=res.Outport{1};
                        end
                    else
                        res=get_param(outpH(portIdx),'CompiledPortDataTypes');
                        if~isempty(res.Inport)
                            portType=res.Inport{1};
                        end
                    end

                    if strcmp(entry.Category,'Value')...
                        &&~isempty(portType)...
                        &&dtTable.hasDeepCopyFunction(portType)
                        msg=DAStudio.message('RTW:fcnClass:portValueNoSupport',...
                        entry.SLObjectName,portType);
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end


                    if strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')&&...
                        strcmp(entry.SLObjectType,'Outport')&&...
                        strcmp(entry.Category,'Value')
                        baseRate=str2double(get_param(hModel,'CompiledStepSize'));
                        locMdlName=get_param(hModel,'Name');
                        locOutBlockName=[locMdlName,'/',entry.SLObjectName];
                        locCompiledSampleTime=get_param(locOutBlockName,'CompiledSampleTime');
                        locCompiledSampleTime=locCompiledSampleTime(1);
                        if baseRate~=locCompiledSampleTime&&locCompiledSampleTime~=-1
                            msg=DAStudio.message('RTW:fcnClass:returnByValueOutputSlowerRate',entry.SLObjectName);
                            DAStudio.error('RTW:fcnClass:finish',msg);
                        end
                    end
                end


                for i=1:numel(outpH)
                    outBlk=outpH(i);
                    outBlkObj=get_param(outBlk,'Object');
                    compiledSampleTime=getCompiledSampleTimeInCodegen(outBlkObj);
                    if isinf(compiledSampleTime(1))&&isinf(compiledSampleTime(2))
                        msg=DAStudio.message('RTW:fcnClass:constantRootOutportCPP',...
                        getfullname(outBlk));
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end
                end
            end

            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');


            if strcmpi(callMode,'finalValidation')&&strcmp(get_param(hModel,'ModelReferenceTargetType'),'NONE')
                for i=1:numel(outBlks)
                    outBlk=outBlks(i);
                    outBlkObj=get_param(outBlk,'Object');
                    if strcmp(outBlkObj.EnsureOutportIsVirtual,'on')
                        msg=DAStudio.message('RTW:fcnClass:argsClassHasVirtualOutport',...
                        nameToReport,getfullname(outBlk));
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end
                end
            end
        end
    catch me
        status=false;
        msg=me.message;
    end
    delete(compileObj);
end

function loc_throwError(msg)

    throwAsCaller(MSLException([],message('RTW:fcnClass:finish',msg.getString)));
end

function loc_syncConfigWithModelForInit(hModel,configData,stepName)
    numOfReturnValue=0;
    position=-9999999;
    names={};

    for i=1:length(configData)
        if isscalar(configData)
            entry=configData;
        else
            entry=configData(i);
        end

        if strcmp(entry.ArgName,stepName)
            msg=DAStudio.message('RTW:fcnClass:fcnNameConflictsArgName',...
            entry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        if strcmp(entry.SLObjectType,'Outport')
            if strcmp(entry.Category,'Value')
                if loc_hasControlPort(hModel)



                    msg=DAStudio.message('RTW:fcnClass:controlPortWithReturnByValue');
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
                numOfReturnValue=numOfReturnValue+1;
                if numOfReturnValue>1
                    msg=DAStudio.message('RTW:fcnClass:tooManyReturnValues');
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end
        end


        if strcmp(entry.Category,'Value')&&...
            (strcmp(entry.Qualifier,'const *')||...
            strcmp(entry.Qualifier,'const * const'))
            msg=DAStudio.message('RTW:fcnClass:valueConstStar',...
            entry.SLObjectName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(entry.Category,'Pointer')&&...
            strcmp(entry.Qualifier,'const')
            msg=DAStudio.message('RTW:fcnClass:pointerConst',...
            entry.SLObjectName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        elseif strcmp(entry.SLObjectType,'Outport')&&...
            (strcmp(entry.Qualifier,'const *')||...
            strcmp(entry.Qualifier,'const * const')||...
            strcmp(entry.Qualifier,'const')||...
            strcmp(entry.Qualifier,'const &'))
            msg=DAStudio.message('RTW:fcnClass:outportConst',...
            entry.SLObjectName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        end


        if position>entry.Position
            msg=DAStudio.message('RTW:fcnClass:sorted');
            DAStudio.error('RTW:fcnClass:finish',msg);
        else
            position=entry.Position;
        end


        if~entry.isValidCPPIdentifier()
            msg=DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',entry.ArgName);
            DAStudio.error('RTW:fcnClass:finish',msg);
        else
            temp=ismember(names,entry.ArgName);
            pos=find(temp);%#ok

            if~isempty(pos)
                if(slfeature('ReuseReusableIOInFPC')==0)
                    msg=DAStudio.message('RTW:fcnClass:argNamesDuplicate',entry.ArgName);
                    DAStudio.error('RTW:fcnClass:finish',msg);
                else
                    [foundCombinedOne,combinedRow,~,~]=...
                    coder.dictionary.internal.foundCombinedIO(entry.Position-1,configData,entry.ArgName);

                    if~foundCombinedOne||(foundCombinedOne&&abs(combinedRow-entry.Position+1)>1)
                        msg=DAStudio.message('RTW:fcnClass:argNamesDuplicate',entry.ArgName);
                        DAStudio.error('RTW:fcnClass:finish',msg);
                    end
                end
            else
                names=[names,entry.ArgName];%#ok
            end
        end
    end
end




function loc_staticMainIncompatibilities(hModel,cs,isTopModelCodegen,cm)
    if isTopModelCodegen&&...
        isValidParam(cs,'GenerateSampleERTMain')&&...
        strcmpi(get_param(cs,'GenerateSampleERTMain'),'off')&&...
        strcmpi(get_param(cs,'CreateSILPILBlock'),'None')&&...
        strcmpi(get_param(cs,'GenCodeOnly'),'off')
        doesPortHavePointerDataAccess=@(port)strcmp(cm.getData(port,'DataAccess'),'Pointer');
        modelElements={'Inports','Outports'};
        for cellElement=modelElements
            element=cellElement{:};
            if doesPortHavePointerDataAccess(element)
                msg=DAStudio.message('coderdictionary:mapping:CppStaticMainPointerDataAccess',get_param(hModel,'name'),element);
                DAStudio.error('RTW:fcnClass:finish',msg);
            end
        end
    end
end

function loc_checkBEPAtRoot(hModel,blockType)

    ports=find_system(hModel,'SearchDepth',1,'BlockType',blockType);
    msgID=['RTW:fcnClass:busElement',blockType];

    for i=1:length(ports)
        if strcmp(get_param(ports(i),'IsBusElementPort'),'on')
            msg=DAStudio.message(msgID,getfullname(ports(i)));
            DAStudio.error('RTW:fcnClass:finish',msg);
        end
    end
end

function flag=loc_hasControlPort(hModel)
    flag=false;

    triggerPortBlk=find_system(hModel,'SearchDepth',1,'BlockType','TriggerPort');
    if~isempty(triggerPortBlk)
        flag=true;
    end

    enablePortBlk=find_system(hModel,'SearchDepth',1,'BlockType','EnablePort');
    if~isempty(enablePortBlk)
        flag=true;
    end
end

function usesFPC=loc_usesFPC(functionPrototype)
    usesFPC=~isempty(functionPrototype)&&...
    (~isempty(functionPrototype.arguments)||~isempty(functionPrototype.returnArguments));
end

