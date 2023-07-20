function[status,msg]=runValidation(hSrc,varargin)
















    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok<NASGU>
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
        msg=message('RTW:fcnClass:invalidMdlHdl').getString;
        return;
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                status=0;
                msg=message('RTW:fcnClass:invalidMdlHdl').getString;
                return;
            end
        catch ex %#ok
            status=0;
            msg=message('RTW:fcnClass:invalidMdlHdl').getString;
            return;
        end
    end

    fullname=getfullname(hModel);
    if hSrc.RightClickBuild
        nameToReport=getfullname(hSrc.SubsysBlockHdl);
    else
        nameToReport=fullname;
    end

    simStatus=get_param(hModel,'SimulationStatus');
    isExportFcnDiagram=...
    strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
    slprivate('getIsExportFcnModel',hModel);

    compileObj=coder.internal.CompileModel;
    if~strcmpi(simStatus,'paused')&&...
        ~strcmpi(simStatus,'initializing')&&...
        ~strcmpi(simStatus,'running')&&...
        ~strcmpi(simStatus,'updating')

        try
            if strcmpi(get_param(hModel,'SimulationMode'),'accelerator')
                throw(MSLException([],message('RTW:fcnClass:accelSimForbiddenForFPC')));
            end
            lastwarn('');

            compileObj.compile(hModel);

            if~isempty(lastwarn)
                disp([message('RTW:fcnClass:fcnProtoCtlWarn').getString,lastwarn]);
            end
        catch ex
            delete(compileObj);
            status=0;
            msg=message('RTW:fcnClass:modelNotCompile',ex.message).getString;
            return;
        end
    end


    if hSrc.RightClickBuild
        cs=getActiveConfigSet(bdroot(hSrc.SubsysBlockHdl));
    else
        cs=getActiveConfigSet(hModel);
    end

    try
        if~hSrc.RightClickBuild&&~isExportFcnDiagram
            fcnCallRootInport=sl('findFcnCallRootInport',hModel);
            if~isempty(fcnCallRootInport)
                loc_throwError(message('RTW:fcnClass:fcnCallRootInport',...
                getfullname(fcnCallRootInport(1))));
            end
        end

        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))

            isCompliant=get_param(cs,'ModelStepFunctionPrototypeControlCompliant');
            if~strcmp(isCompliant,'on')
                loc_throwError(message('RTW:fcnClass:nonMdlStepFcnProtoCompliant'));
            end

            gentestinterface=get_param(cs,'GenerateTestInterfaces');
            if strcmp(gentestinterface,'on')
                loc_throwError(message('RTW:fcnClass:gentestinterface'));
            end

            if strcmp(get_param(cs,'CombineOutputUpdateFcns'),'off')&&~isExportFcnDiagram
                loc_throwError(message('RTW:fcnClass:combineOutputUpdate',nameToReport));
            elseif strcmp(get_param(cs,'MultiInstanceERTCode'),'on')&&...
                slfeature('PluggableInterface')<3
                loc_throwError(message('RTW:fcnClass:reusableCode',nameToReport));
            elseif strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')&&...
                strcmp(get_param(cs,'ModelReferenceNumInstancesAllowed'),'Multi')&&...
                slfeature('PluggableInterface')<3
                loc_throwError(message('RTW:fcnClass:reusableMdlrefCode',nameToReport));
            elseif strcmp(get_param(cs,'SolverType'),'Variable-step')&&...
                ~(hSrc.RightClickBuild)
                loc_throwError(message('RTW:fcnClass:variableStepType',nameToReport));
            end


            if(~isExportFcnDiagram)
                loc_validateFunctionName(hSrc.FunctionName,fullname);
            end


            loc_validateFunctionName(hSrc.InitFunctionName,fullname);


            if~isExportFcnDiagram&&strcmp(hSrc.FunctionName,hSrc.InitFunctionName)
                loc_throwError(message('RTW:fcnClass:fcnNameConflictsInitFcnName'));
            end


            if(~isExportFcnDiagram)
                loc_syncConfigWithModelForInit(hSrc,hModel);
            end
        end

        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'postProp'))||...
            strcmpi(callMode,'finalvalidation')
            if(~isExportFcnDiagram)
                loc_syncConfigWithModelForPostProp(hSrc,hModel)
            end
        end




        multiInstCheck=false;
        if slfeature('PluggableInterface')>=3
            if strcmp(get_param(cs,'MultiInstanceERTCode'),'on')
                multiInstCheck=true;
            elseif strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')&&...
                strcmp(get_param(cs,'ModelReferenceNumInstancesAllowed'),'Multi')
                multiInstCheck=true;
            end
        end



        if strcmpi(callMode,'finalValidation')&&strcmp(get_param(hModel,'ModelReferenceTargetType'),'NONE')

            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                outBlkObj=get_param(outBlk,'Object');
                if strcmp(outBlkObj.EnsureOutportIsVirtual,'on')
                    loc_throwError(message('RTW:fcnClass:argsClassHasVirtualOutport',...
                    nameToReport,getfullname(outBlk)));
                end
            end
        end

        if multiInstCheck&&strcmpi(callMode,'postprop')

            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                outBlkObj=get_param(outBlk,'Object');
                compiledSampleTime=getCompiledSampleTimeInCodegen(outBlkObj);
                if isinf(compiledSampleTime(1))&&isinf(compiledSampleTime(2))
                    loc_throwError(message('RTW:fcnClass:constantRootOutport',...
                    getfullname(outBlk)));
                end
            end
        end

        if(strcmpi(callMode,'interactive')||strcmpi(callMode,'finalValidation'))

            outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                outBlkObj=get_param(outBlk,'Object');
                compiledSampleTime=getCompiledSampleTimeInCodegen(outBlkObj);
                if isinf(compiledSampleTime(1))&&isinf(compiledSampleTime(2))
                    loc_throwError(message('RTW:fcnClass:constantRootOutport',...
                    getfullname(outBlk)));
                end
            end

            if(~isExportFcnDiagram)

                uddobj=get_param(fullname,'UDDObject');
                singleRate=uddobj.outputFcnHasSinglePeriodicRate();

                if~singleRate&&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')

                    loc_throwError(message('RTW:fcnClass:singleTasking',nameToReport));
                end
                if strcmp(get_param(cs,'ConcurrentTasks'),'on')

                    loc_throwError(message('RTW:fcnClass:noConcurrentTasks',nameToReport));
                end
            end


            if strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')
                for i=1:length(hSrc.Data)
                    if isscalar(hSrc.Data)
                        entry=hSrc.Data;
                    else
                        entry=hSrc.Data(i);
                    end
                    if strcmp(entry.SLObjectType,'Outport')&&...
                        strcmp(entry.Category,'Value')
                        baseRate=str2double(get_param(hModel,'CompiledStepSize'));
                        locMdlName=get_param(hModel,'Name');
                        locOutBlockName=[locMdlName,'/',entry.SLObjectName];
                        locCompiledSampleTime=get_param(locOutBlockName,'CompiledSampleTime');
                        locCompiledSampleTime=locCompiledSampleTime(1);
                        if baseRate~=locCompiledSampleTime&&locCompiledSampleTime~=-1
                            loc_throwError(message('RTW:fcnClass:returnByValueOutputSlowerRate',entry.SLObjectName));
                        end
                    end
                end
            end
        end
        delete(compileObj);
    catch ex
        delete(compileObj);
        status=0;
        msg=ex.message;
    end
end


function loc_validateFunctionName(functionName,modelName)
    dummyConfigEntry=RTW.FcnArgSpec;
    dummyConfigEntry.ArgName=functionName;

    if strcmp(functionName,modelName)

        loc_throwError(message('RTW:fcnClass:fcnNameConflictsMdlName',...
        functionName));
    end

    if~dummyConfigEntry.isValidIdentifier()
        loc_throwError(message('RTW:fcnClass:notValidFunctionName',...
        dummyConfigEntry.ArgName));
    end
end




function loc_checkFunctionNameAgainstArgName(functionName,argName)
    if strcmp(argName,functionName)
        loc_throwError(message('RTW:fcnClass:fcnNameConflictsArgName',argName));
    end
end



function loc_syncConfigWithModelForInit(hSrc,hModel)
    configData=hSrc.syncWithModel();

    numOfReturnValue=0;
    position=-9999999;
    names={};

    for i=1:length(configData)
        if isscalar(configData)
            entry=configData;
        else
            entry=configData(i);
        end

        loc_checkFunctionNameAgainstArgName(hSrc.FunctionName,entry.ArgName);
        loc_checkFunctionNameAgainstArgName(hSrc.InitFunctionName,entry.ArgName);

        isInport=true;
        if~strcmp(entry.SLObjectType,'Inport')
            isInport=false;
        end


        if strcmp(entry.SLObjectType,'Outport')
            if strcmp(entry.Category,'Value')
                if hSrc.hasControlPort(hModel)



                    loc_throwError(message('RTW:fcnClass:controlPortWithReturnByValue'));
                end
                numOfReturnValue=numOfReturnValue+1;
                if numOfReturnValue>1
                    loc_throwError(message('RTW:fcnClass:tooManyReturnValues'));
                end
            end
        end


        if strcmp(entry.Category,'Value')&&...
            (strcmp(entry.Qualifier,'const *')||...
            strcmp(entry.Qualifier,'const * const'))
            loc_throwError(message('RTW:fcnClass:valueConstStar',...
            entry.SLObjectName));
        elseif strcmp(entry.Category,'Pointer')&&...
            strcmp(entry.Qualifier,'const')
            loc_throwError(message('RTW:fcnClass:pointerConst',...
            entry.SLObjectName));
        elseif~isInport&&(strcmp(entry.Qualifier,'const *')||...
            strcmp(entry.Qualifier,'const * const')||...
            strcmp(entry.Qualifier,'const'))
            loc_throwError(message('RTW:fcnClass:outportConst',...
            entry.SLObjectName));
        end


        if position>entry.Position
            loc_throwError(message('RTW:fcnClass:sorted'));
        else
            position=entry.Position;
        end


        if~entry.isValidIdentifier()
            loc_throwError(message('RTW:fcnClass:notValidIdentifier',entry.ArgName));
        else
            temp=ismember(names,entry.ArgName);
            pos=find(temp);%#ok

            if~isempty(pos)
                if(slfeature('ReuseReusableIOInFPC')==0)
                    loc_throwError(message('RTW:fcnClass:argNamesDuplicate',entry.ArgName));
                else
                    [foundCombinedOne,combinedRow,~,~]=...
                    hSrc.foundCombinedIO(entry.Position-1,configData,entry.ArgName);

                    if~foundCombinedOne||(foundCombinedOne&&abs(combinedRow-entry.Position+1)>1)
                        loc_throwError(message('RTW:fcnClass:argNamesDuplicate',entry.ArgName));
                    end
                end
            else
                names=[names,entry.ArgName];%#ok
            end
        end
    end
    hSrc.Data=configData;
end



function loc_syncConfigWithModelForPostProp(hSrc,hModel)

    configData=hSrc.syncWithModel();

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
        foundCGVCEOnSharedArgs=false;
        if foundCombinedOne
            [foundCGVCEOnSharedArgs,firstIO,secondIO]=...
            hSrc.foundCombinedIOWithCGVCE(entry.Position-1,configData,entry.ArgName,inpH,outpH);

            if foundCGVCEOnSharedArgs
                loc_throwError(message('RTW:fcnClass:combinedIOCGVCEMismatch',firstIO,secondIO,entry.ArgNam));
            end
        end

        if foundCombinedOne&&~foundCGVCEOnSharedArgs

            if~strcmp(entry.Category,configData(combinedRow+1).Category)
                loc_throwError(message('RTW:fcnClass:combinedIOCategoryMismatch',entry.ArgNam));
            end
            if strcmp(entry.Category,'Value')
                loc_throwError(message('RTW:fcnClass:noValueForCombinedIO',entry.SLObjectName));
            end
            if~isempty(strfind(entry.Qualifier,'const'))
                loc_throwError(message('RTW:fcnClass:noConstForCombinedIO',entry.SLObjectName));
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
                loc_throwError(message('RTW:fcnClass:combinedIODataTypeMismatch',entry.ArgNam));
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
                    loc_throwError(message('RTW:fcnClass:combinedIODataTypeMismatch',...
                    entry.ArgName));
                end


                previousDim=[];
            else


                previousDim=dimensions;
            end
        end

        if~isempty(csc)&&~strcmp(csc,'Auto')
            loc_throwError(message('RTW:fcnClass:customStorageClass',...
            entry.SLObjectName));
        end


        if any(dimsMode)
            loc_throwError(message('RTW:fcnClass:variableSizeSignal',...
            entry.SLObjectName));
        end


        for index=1:length(dimensions)
            if dimensions(index)>1&&...
                strcmp(entry.Category,'Value')
                loc_throwError(message('RTW:fcnClass:portValue',...
                entry.SLObjectName));
            end
        end
    end
end


function loc_throwError(msg)

    throwAsCaller(MSLException([],message('RTW:fcnClass:finish',msg.getString)));
end



