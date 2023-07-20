function[status,msg]=runValidation(hSrc,varargin)
















    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    status=1;
    msg='';

    if nargin==2
        callMode=varargin{1};
    else
        callMode='interactive';
    end

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
        catch me %#ok
            status=0;
            msg=DAStudio.message('RTW:fcnClass:invalidMdlHdl');
            return;
        end
    end

    fullname=getfullname(hModel);

    simStatus=get_param(hModel,'SimulationStatus');

    compileObj=coder.internal.CompileModel;

    if hSrc.needsCompilation()&&...
        ~strcmpi(simStatus,'paused')&&~strcmpi(simStatus,'initializing')&&...
        ~strcmpi(simStatus,'running')
        try
            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                DAStudio.error('RTW:fcnClass:accelSimForbiddenForCPP')
            end
            isExportFcnDiagram=...
            strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
            slprivate('getIsExportFcnModel',hModel);

            if isExportFcnDiagram
                DAStudio.error('RTW:fcnClass:ioArgsExportFunctionModel');
            end
            lastwarn('');

            compileObj.compile(hModel);

            if~isempty(lastwarn)
                disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
            end
        catch me
            status=0;
            msg=DAStudio.message('RTW:fcnClass:modelNotCompile',me.message);
            return;
        end
    end

    try
        configData=hSrc.syncWithModel();
        [status,msg]=hSrc.supValidation();

        if(~status)

            DAStudio.error('RTW:fcnClass:finish',msg);
        end

        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))
            loc_syncConfigWithModelForInit(hSrc,hModel,configData);
        end

        isExportFcnDiagram=...
        strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
        slprivate('getIsExportFcnModel',hModel);
        if~hSrc.RightClickBuild&&~isExportFcnDiagram
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

            [inpH,outpH]=hSrc.getPortHandles(hModel);

            previousDim=[];
            for i=1:length(configData)
                if isscalar(configData)
                    entry=configData;
                else
                    entry=configData(i);
                end

                [csc,dimensions,dimsMode]=hSrc.getPortProperties(entry,inpH,outpH);

                [foundCombinedOne,combinedRow,~,~]=...
                hSrc.foundCombinedIO(entry.Position-1,configData,entry.ArgName);

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
                dtTable=Simulink.internal.DataTypeTable(fullname);
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


            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                outBlkObj=get_param(outBlk,'Object');
                compiledSampleTime=getCompiledSampleTimeInCodegen(outBlkObj);
                if isinf(compiledSampleTime(1))&&isinf(compiledSampleTime(2))
                    msg=DAStudio.message('RTW:fcnClass:constantRootOutportCPP',...
                    getfullname(outBlk));
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end



            mmgr=get_param(fullname,'MappingManager');
            [~,currentMapping]=Simulink.CodeMapping.getCurrentMapping(fullname);
            usesCppMapping=strcmp(currentMapping,'CppModelMapping');
            cs=getActiveConfigSet(hModel);

            if~usesCppMapping
                uddobj=get_param(fullname,'UDDObject');
                singleRate=uddobj.outputFcnHasSinglePeriodicRate();

                if~singleRate&&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')

                    msg=DAStudio.message('RTW:fcnClass:cppSingleTasking');
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end

            isExportFcnDiagram=...
            strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
            slprivate('getIsExportFcnModel',hModel);

            if isExportFcnDiagram
                DAStudio.error('RTW:fcnClass:ioArgsExportFunctionModel');
            end

            if strcmpi(get_param(cs,'IsERTTarget'),'on')&&~strcmp(get_param(cs,'ZeroExternalMemoryAtStartup'),'off')
                msg=DAStudio.message('RTW:fcnClass:cppNonvoidvoidExternalIOInit');
                DAStudio.error('RTW:fcnClass:finish',msg);
            end

        end



        if strcmpi(callMode,'finalValidation')&&strcmp(get_param(hModel,'ModelReferenceTargetType'),'NONE')
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                outBlkObj=get_param(outBlk,'Object');
                if strcmp(outBlkObj.EnsureOutportIsVirtual,'on')
                    msg=DAStudio.message('RTW:fcnClass:argsClassHasVirtualOutport',...
                    fullname,getfullname(outBlk));
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end
        end

        delete(compileObj);
    catch me
        delete(compileObj);
        status=0;
        msg=me.message;
    end
    delete(sess);

    function loc_syncConfigWithModelForInit(hSrc,hModel,configData)
        numOfReturnValue=0;
        position=-9999999;
        names={};

        for i=1:length(configData)
            if isscalar(configData)
                entry=configData;
            else
                entry=configData(i);
            end

            if strcmp(entry.ArgName,hSrc.FunctionName)
                msg=DAStudio.message('RTW:fcnClass:fcnNameConflictsArgName',...
                entry.ArgName);
                DAStudio.error('RTW:fcnClass:finish',msg);
            end


            if strcmp(entry.SLObjectType,'Outport')
                if strcmp(entry.Category,'Value')
                    if hSrc.hasControlPort(hModel)



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
                        hSrc.foundCombinedIO(entry.Position-1,configData,entry.ArgName);

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

        hSrc.Data=configData;

        function loc_checkBEPAtRoot(hModel,blockType)

            ports=find_system(hModel,'SearchDepth',1,'BlockType',blockType);
            msgID=['RTW:fcnClass:busElement',blockType];

            for i=1:length(ports)
                if strcmp(get_param(ports(i),'IsBusElementPort'),'on')
                    msg=DAStudio.message(msgID,getfullname(ports(i)));
                    DAStudio.error('RTW:fcnClass:finish',msg);
                end
            end



