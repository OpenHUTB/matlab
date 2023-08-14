function runValidation(hModel,varargin)






    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);%#ok<NASGU>

    if nargin==2
        callMode=varargin{1};
    else
        callMode='interactive';
    end

    if~ishandle(hModel)
        loc_throwError(message('RTW:fcnClass:invalidMdlHdl'));
        return;
    else
        try
            obj=get_param(hModel,'object');
            if~obj.isa('Simulink.BlockDiagram')
                loc_throwError(message('RTW:fcnClass:invalidMdlHdl'));
            end
        catch ex %#ok
            loc_throwError(message('RTW:fcnClass:invalidMdlHdl'));
        end
    end

    nameToReport=getfullname(hModel);

    modelMapping=Simulink.CodeMapping.getCurrentMapping(hModel);
    prototype=modelMapping.OutputFunctionMappings(1).Prototype;

    try
        func=coder.parser.Parser.doit(prototype);
    catch
        loc_throwError(message('coderdictionary:mapping:InvalidPrototype',prototype));
    end
    targetLang=get_param(hModel,'CodeInterfacePackaging');
    isCppMapping=strcmp(targetLang,'C++ class');

    skipArgumentSyncing=isempty(func.arguments)||...
    (length(func.arguments)==1&&...
    strcmp(func.arguments{1}.name,'CHECKED'));
    if~skipArgumentSyncing&&~isCppMapping&&...
        (strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))





        fcnClsObj=get_param(hModel,'RTWFcnClass');
        fcnClsObj.ModelHandle=hModel;
        fcnClsObj.syncWithModel;
        set_param(hModel,'RTWFcnClass',fcnClsObj)

        prototype=modelMapping.OutputFunctionMappings(1).Prototype;
        func=coder.parser.Parser.doit(prototype);
    end


    loc_checkBEPAtRoot(hModel,'Inport');
    loc_checkBEPAtRoot(hModel,'Outport');

    if strcmpi(callMode,'interactive')||strcmpi(callMode,'init')
        if isempty(func.name)
            loc_throwError(message('RTW:fcnClass:notValidFunctionName',...
            prototype));
        end

        if isempty(func.arguments)&&isempty(func.returnArguments)


            loc_validateFunctionName(func.name,nameToReport);
            return;
        end

        mapping=Simulink.CodeMapping.get(hModel,'CoderDictionary');
        if~isempty(mapping)
            inportDefaultSC=coder.api.internal.getDataDefaults(hModel,'Inports','StorageClass');
            outportDefaultSC=coder.api.internal.getDataDefaults(hModel,'Outports','StorageClass');

            if~strcmpi(inportDefaultSC,'Default')&&~strcmpi(inportDefaultSC,'Dictionary default')

                loc_throwError(message('coderdictionary:mapping:InportSCPresent',inportDefaultSC));
            end

            if~strcmpi(outportDefaultSC,'Default')&&~strcmpi(outportDefaultSC,'Dictionary default')

                loc_throwError(message('coderdictionary:mapping:OutportSCPresent',outportDefaultSC));
            end

            if strcmpi(inportDefaultSC,'Dictionary default')
                dictDefault=coder.mapping.defaults.get(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(hModel,'Handle')),'Inports','StorageClass');
                if~strcmpi(dictDefault,'Default')
                    loc_throwError(message('coderdictionary:mapping:InportSCPresent',dictDefault));
                end
            end

            if strcmpi(outportDefaultSC,'Dictionary default')
                dictDefault=coder.mapping.defaults.get(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(hModel,'Handle')),'Outports','StorageClass');
                if~strcmpi(dictDefault,'Default')
                    loc_throwError(message('coderdictionary:mapping:OutportSCPresent',dictDefault));
                end
            end
        end
    end

    if strcmpi(callMode,'interactive')
        [inpH,outpH]=coder.mapping.internal.StepFunctionMapping.getPortHandles(hModel);
        argMap=containers.Map;
        for i=1:length(inpH)
            SID=get_param(inpH(i),'SID');
            argMap(SID)='in';
        end

        for i=1:length(outpH)
            SID=get_param(outpH(i),'SID');
            argMap(SID)='out';
        end

        if~isempty(func.returnArguments)
            if~argMap.isKey(func.returnArguments{1}.mappedFrom{1})
                portName=Simulink.ID.getHandle([nameToReport,':',func.returnArguments{1}.mappedFrom{1}]);

                loc_throwError(message('coderdictionary:mapping:PortNameNotPresent'...
                ,portName));
            end
        end

        for i=1:length(func.arguments)
            if~isempty(func.arguments{i}.mappedFrom)

                if~argMap.isKey(func.arguments{i}.mappedFrom{1})
                    portName=Simulink.ID.getHandle([nameToReport,':',func.arguments{i}.mappedFrom{1}]);

                    loc_throwError(message('coderdictionary:mapping:PortNameNotPresent',...
                    portName));
                end
            end
        end
    end


    isExportFcnDiagram=...
    strcmp(get_param(hModel,'SolverType'),'Fixed-step')&&...
    slprivate('getIsExportFcnModel',hModel);


    simStatus=get_param(hModel,'SimulationStatus');
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
            for i=1:length(ex.cause)
                stageName=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceFor',nameToReport).getString;
                myStage=Simulink.output.Stage(stageName,'ModelName',get_param(hModel,'name'),...
                'UIMode',true);
                Simulink.output.error(ex.cause{i});
                myStage.delete;
            end
            loc_throwError(message('RTW:fcnClass:modelNotCompile',ex.message));
        end
    end

    cs=getActiveConfigSet(hModel);

    if~isExportFcnDiagram
        fcnCallRootInport=sl('findFcnCallRootInport',hModel);
        if~isempty(fcnCallRootInport)
            loc_throwError(message('RTW:fcnClass:fcnCallRootInport',...
            getfullname(fcnCallRootInport(1))));
        end
    end
    [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(hModel);
    isCppMapping=strcmp(mappingType,'CppModelMapping');

    if(strcmpi(callMode,'interactive')||strcmpi(callMode,'init'))&&...
        ~isCppMapping

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

        elseif strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')&&...
            strcmp(get_param(cs,'ModelReferenceNumInstancesAllowed'),'Multi')&&...
            slfeature('PluggableInterface')<3
            loc_throwError(message('RTW:fcnClass:reusableMdlrefCode',nameToReport));
        elseif strcmp(get_param(cs,'SolverType'),'Variable-step')
            loc_throwError(message('RTW:fcnClass:variableStepType',nameToReport));
        end


        stepFcnName=func.name;
        if(~isExportFcnDiagram)
            try
                loc_validateFunctionName(stepFcnName,nameToReport);
            catch ME
                rethrow(ME);
            end
        end

        [inpH,outpH]=coder.mapping.internal.StepFunctionMapping.getPortHandles(hModel);
        numArgs=length(func.arguments)+length(func.returnArguments);
        if(length(inpH)+length(outpH))~=numArgs||(length(func.arguments)==1&&strcmp(func.arguments{1}.name,'CHECKED')&&isempty(func.arguments{1}.mappedFrom))
            prototype=erase(prototype,'CHECKED');
            prototype=coder.mapping.internal.StepFunctionMapping.updateMapping(hModel,prototype);
            mapping=Simulink.CodeMapping.get(hModel,'CoderDictionary');
            if~isempty(mapping)
                mapping.OutputFunctionMappings(1).Prototype=prototype;
                func=coder.parser.Parser.doit(prototype);
            end
        end

        args=loc_parsePrototype(func,hModel);

        if(~isExportFcnDiagram)
            try
                loc_syncConfigWithModelForInit(stepFcnName,args,hModel);
            catch ME
                rethrow(ME);
            end
        end
    end
    if~isCppMapping
        args=loc_parsePrototype(func,hModel);

        if strcmpi(callMode,'codegen')||strcmpi(callMode,'interactive')
            if(~isExportFcnDiagram)
                try
                    loc_syncConfigWithModelForPostProp(args,hModel)
                catch ME
                    rethrow(ME);
                end
            end
        end
    end
    if(strcmpi(callMode,'interactive')||strcmpi(callMode,'codegen'))

        outBlks=find_system(hModel,'SearchDepth',1,'BlockType','Outport');
        for i=1:numel(outBlks)
            outBlk=outBlks(i);
            outBlkObj=get_param(outBlk,'Object');
            compiledSampleTime=getCompiledSampleTimeInCodegen(outBlkObj);
            if iscell(compiledSampleTime)
                for j=1:length(compiledSampleTime)
                    cst=compiledSampleTime{j};
                    if isinf(cst(1))&&isinf(cst(2))
                        loc_throwError(message('RTW:fcnClass:constantRootOutport',...
                        getfullname(outBlk)));
                    end
                end
            else
                if isinf(compiledSampleTime(1))&&isinf(compiledSampleTime(2))
                    loc_throwError(message('RTW:fcnClass:constantRootOutport',...
                    getfullname(outBlk)));
                end
            end
        end

        if(~isExportFcnDiagram)

            uddobj=get_param(nameToReport,'UDDObject');
            singleRate=uddobj.outputFcnHasSinglePeriodicRate();

            if~singleRate&&~strcmp(get_param(cs,'SolverMode'),'SingleTasking')

                loc_throwError(message('RTW:fcnClass:singleTasking',nameToReport));
            end
            if strcmp(get_param(cs,'ConcurrentTasks'),'on')

                loc_throwError(message('RTW:fcnClass:noConcurrentTasks',nameToReport));
            end
        end

        if~isCppMapping
            args=loc_parsePrototype(func,hModel);


            if strcmp(get_param(hModel,'ModelReferenceTargetType'),'RTW')
                for i=1:length(args)
                    entry=args(i);
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
    end



    if strcmpi(callMode,'codegen')&&strcmp(get_param(hModel,'ModelReferenceTargetType'),'NONE')
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
end




function loc_validateFunctionName(functionName,modelName)
    if isempty(functionName)
        return;
    end
    if strcmp(functionName,modelName)

        loc_throwError(message('RTW:fcnClass:fcnNameConflictsMdlName',...
        functionName));
    end

    hasMapping=~isempty(Simulink.CodeMapping.get(modelName,'CoderDictionary'));
    if~loc_isValidIdentifier(functionName,hasMapping)
        loc_throwError(message('RTW:fcnClass:notValidFunctionName',...
        functionName));
    end
end




function loc_checkFunctionNameAgainstArgName(functionName,argName)
    if strcmp(argName,functionName)
        loc_throwError(message('RTW:fcnClass:fcnNameConflictsArgName',argName));
    end
end



function loc_syncConfigWithModelForInit(stepFcnName,args,hModel)

    names={};

    for i=1:length(args)
        entry=args(i);

        loc_checkFunctionNameAgainstArgName(stepFcnName,entry.ArgName);

        isInport=true;
        if~strcmp(entry.SLObjectType,'Inport')
            isInport=false;
        end


        if strcmp(entry.SLObjectType,'Outport')
            if strcmp(entry.Category,'Value')

                hasControlPort=false;
                triggerPortBlk=find_system(hModel,'SearchDepth',1,'BlockType','TriggerPort');
                if~isempty(triggerPortBlk)
                    hasControlPort=true;
                end

                enablePortBlk=find_system(hModel,'SearchDepth',1,'BlockType','EnablePort');
                if~isempty(enablePortBlk)
                    hasControlPort=true;
                end
                if hasControlPort



                    loc_throwError(message('RTW:fcnClass:controlPortWithReturnByValue'));
                end
            end
        end


        qualifier=entry.Qualifier;
        despacedQualifier=qualifier(~isspace(qualifier));
        constPointer='const *';
        despacedConstPointer=constPointer(~isspace(constPointer));
        constPointerToConst='const * const';
        despacedConstPointerToConst=constPointerToConst(~isspace(constPointerToConst));
        isConstPointer=strcmp(despacedQualifier,despacedConstPointer);
        isConstPointerToConst=strcmp(despacedQualifier,despacedConstPointerToConst);
        isConst=strcmp(despacedQualifier,'const');

        if strcmp(entry.Category,'Value')&&...
            (isConstPointer||...
            isConstPointerToConst)
            loc_throwError(message('RTW:fcnClass:valueConstStar',...
            entry.SLObjectName));
        elseif strcmp(entry.Category,'Pointer')&&...
isConst
            loc_throwError(message('RTW:fcnClass:pointerConst',...
            entry.SLObjectName));
        elseif~isInport&&(isConstPointer||...
            isConstPointerToConst||...
            isConst)
            loc_throwError(message('RTW:fcnClass:outportConst',...
            entry.SLObjectName));
        end


        if~loc_isValidIdentifier(entry.ArgName,false)
            loc_throwError(message('RTW:fcnClass:notValidIdentifier',entry.ArgName));
        else
            temp=ismember(names,entry.ArgName);
            pos=find(temp);%#ok

            if~isempty(pos)
                if(slfeature('ReuseReusableIOInFPC')==0)
                    loc_throwError(message('RTW:fcnClass:argNamesDuplicate',entry.name));
                else
                    [foundCombinedOne,combinedRow,~,msgId]=...
                    loc_foundCombinedIO(i-1,args,entry.ArgName);

                    if~foundCombinedOne
                        if isempty(msgId)
                            loc_throwError(message('RTW:fcnClass:argNamesDuplicate',entry.ArgName));
                        else
                            loc_throwError(message(msgId));
                        end
                    elseif(foundCombinedOne&&abs(combinedRow-i+1)>1)

                        loc_throwError(message('coderdictionary:mapping:StepFPCombinedIOOrdering'));
                    end
                end
            else
                names=[names,entry.ArgName];%#ok
            end
        end
    end
end



function loc_syncConfigWithModelForPostProp(args,hModel)



    [inpH,outpH]=loc_getPortHandles(hModel);
    previousDim=[];
    for i=1:length(args)
        entry=args(i);

        [csc,dimensions,dimsMode]=coder.dictionary.internal.getPortProperties(entry,inpH,outpH);

        [foundCombinedOne,combinedRow,~,~]=...
        loc_foundCombinedIO(i-1,args,entry.ArgName);
        foundCGVCEOnSharedArgs=false;
        if foundCombinedOne
            [foundCGVCEOnSharedArgs,firstIO,secondIO]=...
            loc_foundCombinedIOWithCGVCE(i-1,args,entry.ArgName,inpH,outpH);

            if foundCGVCEOnSharedArgs
                loc_throwError(message('RTW:fcnClass:combinedIOCGVCEMismatch',firstIO,secondIO,entry.ArgName));
            end
        end

        if foundCombinedOne&&~foundCGVCEOnSharedArgs

            if~strcmp(entry.Category,args(combinedRow+1).Category)
                loc_throwError(message('RTW:fcnClass:combinedIOCategoryMismatch',entry.ArgName));
            end
            if strcmp(entry.Category,'Value')
                loc_throwError(message('RTW:fcnClass:noValueForCombinedIO',entry.SLObjectName));
            end
            if~isempty(strfind(entry.Qualifier,'const'))
                loc_throwError(message('RTW:fcnClass:noConstForCombinedIO',entry.SLObjectName));
            end

            mdlName=get_param(hModel,'Name');
            bName1=[mdlName,'/',entry.SLObjectName];
            bName2=[mdlName,'/',args(combinedRow+1).SLObjectName];

            tmp=get_param(bName1,'CompiledPortDataTypes');
            if strcmp(entry.SLObjectType,'Outport')
                pType1=tmp.Inport;
            else
                pType1=tmp.Outport;
            end

            tmp=get_param(bName2,'CompiledPortDataTypes');
            if strcmp(args(combinedRow+1).SLObjectType,'Outport')
                pType2=tmp.Inport;
            else
                pType2=tmp.Outport;
            end

            if~strcmp(pType1,pType2)
                loc_throwError(message('RTW:fcnClass:combinedIODataTypeMismatch',entry.ArgName));
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
                if strcmp(entry.SLObjectType,'Outport')
                    loc_throwError(message('coderdictionary:mapping:OutputArgReturnByVal',...
                    entry.SLObjectName));
                else
                    loc_throwError(message('RTW:fcnClass:portValue',...
                    entry.SLObjectName));
                end
            end
        end
    end
end


function[inpH,outpH]=loc_getPortHandles(hModel)

    inpH=find_system(hModel,'SearchDepth',1,'Type','block',...
    'BlockType','Inport');
    outpH=find_system(hModel,'SearchDepth',1,'Type','block',...
    'BlockType','Outport');
    triggerH=find_system(hModel,'SearchDepth',1,'Type','block',...
    'BlockType','TriggerPort');
    enableH=find_system(hModel,'SearchDepth',1,'Type','block',...
    'BlockType','EnablePort');


    if~isempty(enableH)
        assert(length(enableH)==1);
        inpH=[inpH;enableH];
    end

    if~isempty(triggerH)
        assert(length(triggerH)==1);
        trigType=get_param(triggerH,'TriggerType');

        if~strcmpi(trigType,'function-call')
            inpH=[inpH;triggerH];
        end
    end
end


function loc_throwError(msg)

    throwAsCaller(MSLException([],message('RTW:fcnClass:finish',msg.getString)));
end


function flag=loc_isValidIdentifier(argName,allowTokens)



    flag=true;






    if isempty(argName)||~ischar(argName)
        flag=false;
        return;
    end

    if allowTokens



        validDecorators={'[u]','[u_]','[l]','[l_]','[uL]',...
        '[uL_]','[lU]','[U]','[U_]','[L]','[L_]'};
        extractedDecorators=regexp(argName,'\[.*?\]','match');
        for decorator=extractedDecorators
            if~any(strcmp(decorator{1},validDecorators))
                flag=false;
                return;
            end
        end


        validTokens={'$R','$N','$U','$M'};
        extractedTokens=regexp(argName,'\$.+?','match');
        tokensMap=containers.Map;
        for token=extractedTokens
            if~any(strcmp(token{1},validTokens))
                flag=false;
                return;
            end

            if tokensMap.isKey(token{1})
                flag=false;
                return;
            end
            tokensMap(token{1})='';
        end



        repFcnName=regexprep(argName,'\[.*?\]|\$.+?','a');

        if strcmp(repFcnName(1),'_')
            repFcnName(1)='a';
        end

        if~isvarname(repFcnName)
            flag=false;
            return;
        end

    else



        if~((argName(1)>='a'&&argName(1)<='z')||...
            (argName(1)>='A'&&argName(1)<='Z')||...
            (argName(1)=='_'))
            flag=false;
            return;
        end

        allowedChars='_';
        for i=2:length(argName)
            if(argName(i)>='a'&&argName(i)<='z')||...
                (argName(i)>='A'&&argName(i)<='Z')||...
                (argName(i)>='0'&&argName(i)<='9')
                continue;
            end

            temp=ismember(allowedChars,argName(i));
            pos=find(temp,1);
            if isempty(pos)
                flag=false;
                return;
            end
        end
    end

    reservedChars={'auto','break','case','char','const','continue',...
    'default','do','double','else','enum','extern',...
    'float','for','goto','if','int','long','register',...
    'return','short','signed','sizeof','static','struct',...
    'switch','typedef','union','unsigned','void','volatile',...
    'while'};

    temp=ismember(reservedChars,argName);
    pos=find(temp,1);
    if~isempty(pos)
        flag=false;
        return;
    end

end

function args=loc_parsePrototype(func,modelHandle)
    initialArgs=[func.returnArguments,func.arguments];
    numArgs=length(func.arguments)+length(func.returnArguments);
    args=struct('ArgName',{},'Category',{},'SLObjectType',{},'Qualifier',{},'PortNum',{},'SLObjectName',{});
    for i=1:numArgs
        args(i).ArgName=initialArgs{i}.name;

        if strcmpi(char(initialArgs{i}.passBy),'Pointer')&&strcmpi(initialArgs{i}.qualifier,'Const')
            args(i).Qualifier='const*';
        elseif strcmpi(initialArgs{i}.qualifier,'ConstPointerToConstData')
            args(i).Qualifier='const*const';
        elseif strcmpi(initialArgs{i}.qualifier,'None')
            args(i).Qualifier='none';
        elseif strcmpi(initialArgs{i}.qualifier,'Const')
            args(i).Qualifier='const';
        end

        args(i).Category=char(initialArgs{i}.passBy);

        modelname=get_param(modelHandle,'Name');
        SLObjectName=Simulink.ID.getFullName([modelname,':',initialArgs{i}.mappedFrom{1}]);

        name=SLObjectName;
        blockType=get_param(name,'BlockType');
        if isequal(blockType,'TriggerPort')||...
            isequal(blockType,'EnablePort')
            DAStudio.error('coderdictionary:api:UnsupportedControlPortForPeriodicFPC');
        end
        args(i).SLObjectType=blockType;

        args(i).PortNum=str2double(get_param(name,'Port'))-1;

        args(i).SLObjectName=get_param(name,'Name');
    end
end

function[ret,foundIdx,isTopOrBottom,msgId]=loc_foundCombinedIO(r,data,val)
    ret=false;
    isTopOrBottom=false;
    msgId='';

    thisPortType=data(r+1).SLObjectType;

    count=0;
    foundIdx=-1;

    for i=0:(length(data)-1)
        if i~=r
            curPortType=data(i+1).SLObjectType;

            if strcmp(data(i+1).ArgName,val)
                count=count+1;
                if count>1

                    msgId='RTW:fcnClass:onePairPerCombinedIO';
                else
                    if~strcmp(curPortType,thisPortType)
                        foundIdx=i;
                    else

                        msgId='RTW:fcnClass:inportOutportPairForCombinedIO';
                    end
                end
            end
        end
    end

    if count==1&&foundIdx~=-1
        ret=true;

        if(foundIdx==length(data)-1)||(r==length(data)-1)||(foundIdx==0)||(r==0)
            isTopOrBottom=true;
        end
    end
end




function[ret,firstIO,secondIO]=loc_foundCombinedIOWithCGVCE(r,data,val,inpH,outpH)



    ret=false;
    thisPortType=data(r+1).SLObjectType;
    for i=0:(length(data)-1)
        if i~=r
            curPortType=data(i+1).SLObjectType;

            if strcmp(data(i+1).ArgName,val)
                if~strcmp(curPortType,thisPortType)


                    firstConflictPortIdx=data(r+1).PortNum+1;
                    secondConflictPortIdx=data(i+1).PortNum+1;
                    if strcmp(thisPortType,'Inport')
                        firstCGVCE=get_param(inpH(firstConflictPortIdx),'CompiledLocalCGVCE');
                        firstIO=get_param(inpH(firstConflictPortIdx),'Name');
                    else
                        firstCGVCE=get_param(outpH(firstConflictPortIdx),'CompiledLocalCGVCE');
                        firstIO=get_param(outpH(firstConflictPortIdx),'Name');
                    end
                    if strcmp(curPortType,'Inport')
                        secondCGVCE=get_param(inpH(secondConflictPortIdx),'CompiledLocalCGVCE');
                        secondIO=get_param(inpH(secondConflictPortIdx),'Name');
                    else
                        secondCGVCE=get_param(outpH(secondConflictPortIdx),'CompiledLocalCGVCE');
                        secondIO=get_param(outpH(secondConflictPortIdx),'Name');
                    end

                    if(~isempty(firstCGVCE)&&~strcmp(firstCGVCE,'false'))||...
                        (~isempty(secondCGVCE)&&~strcmp(secondCGVCE,'false'))

                        ret=true;
                    end
                end
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



