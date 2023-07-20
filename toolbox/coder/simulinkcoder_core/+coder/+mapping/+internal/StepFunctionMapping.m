




classdef StepFunctionMapping


    methods(Static,Access=public)
        function isCtrlPort=isControlPort(blockType)


            switch(blockType)
            case{'EnablePort','TriggerPort'}
                isCtrlPort=true;
            otherwise
                isCtrlPort=false;
            end
        end
        function fcnClsObj=getModelSpecificCPrototype(prototype,initName,hModel)
            fcnClsObj=[];
            if~contains(prototype,["(",")","="])


                return;
            end

            modelname=get_param(hModel,'Name');

            fcnClsObj=RTW.ModelSpecificCPrototype;
            func=coder.parser.Parser.doit(prototype);
            if strcmpi(func.name,'USE_DEFAULT_FROM_FUNCTION_CLASSES')

                namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping...
                (hModel,'Execution');
                if isempty(namingRule)
                    namingRule='$R$N';
                end
            else
                namingRule=func.name;
            end

            name=slInternal('getIdentifierUsingNamingService',...
            modelname,namingRule,'step');
            if isempty(name)
                name=func.name;
            end
            fcnClsObj.setFunctionName(name,'step');

            if isempty(initName)

                namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping...
                (hModel,'InitializeTerminate');
                if isempty(namingRule)
                    namingRule='$R$N';
                end
            else
                namingRule=initName;
            end

            tempInitName=slInternal('getIdentifierUsingNamingService',...
            modelname,namingRule,'initialize');
            if~isempty(tempInitName)
                initName=tempInitName;
            end

            fcnClsObj.setFunctionName(initName,'init');
            returnArgPresent=false;

            if~isempty(func.returnArguments)&&~isempty(func.returnArguments{1}.mappedFrom)
                r=func.returnArguments{1};
                SLObjectName=Simulink.ID.getFullName([modelname,':',r.mappedFrom{1}]);
                portName=get_param(SLObjectName,'Name');
                fcnClsObj.addArgConf(portName,char(r.passBy),r.name,char(r.qualifier));
                fcnClsObj.Data(1).PositionString='Return';
                fcnClsObj.Data(1).SLObjectType='Outport';

                name=SLObjectName;
                fcnClsObj.Data(1).PortNum=str2double(get_param(name,'Port'))-1;
                returnArgPresent=true;
            end

            for i=1:length(func.arguments)
                if isempty(func.arguments{i}.mappedFrom)
                    continue;
                end
                a=func.arguments{i};
                q=char(a.qualifier);
                if strcmpi(char(a.passBy),'Pointer')&&strcmpi(q,'Const')
                    q='const*';
                elseif strcmpi(q,'ConstPointerToConstData')
                    q='const*const';
                end
                SLObjectName=Simulink.ID.getFullName([modelname,':',a.mappedFrom{1}]);
                portName=get_param(SLObjectName,'Name');
                fcnClsObj.addArgConf(portName,char(a.passBy),a.name,q);
                if(returnArgPresent)
                    index=i+1;
                else
                    index=i;
                end
                fcnClsObj.Data(index).PositionString=int2str(i);
                name=SLObjectName;
                blockType=get_param(name,'BlockType');
                if isequal(blockType,'TriggerPort')||...
                    isequal(blockType,'EnablePort')
                    DAStudio.error('coderdictionary:api:UnsupportedControlPortForPeriodicFPC');
                end

                fcnClsObj.Data(index).SLObjectType=blockType;
                fcnClsObj.Data(index).PortNum=str2double(get_param(name,'Port'))-1;
            end

            fcnClsObj.ModelHandle=hModel;
            if~isempty(fcnClsObj.Data)

                fcnClsObj.Data=fcnClsObj.syncWithModel;
            end
            fcnClsObj.ArgSpecData=fcnClsObj.Data;
        end

        function fcnClsObj=getModelCPPArgsClass(prototype,initName,hModel)
            fcnClsObj=[];
            if~contains(prototype,["(",")","="])


                return;
            end

            modelname=get_param(hModel,'Name');

            fcnClsObj=RTW.ModelCPPArgsClass;
            fcnClsObj.ModelHandle=hModel;
            func=coder.parser.Parser.doit(prototype);
            nFuncArgs=length(func.arguments);
            if~isempty(func.returnArguments)
                nFuncArgs=nFuncArgs+1;
            end
            res=[];
            for i=1:nFuncArgs
                res=[res,RTW.CPPFcnArgSpec()];
            end
            fcnClsObj.Data=res;

            if strcmpi(func.name,'USE_DEFAULT_FROM_FUNCTION_CLASSES')

                namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping...
                (hModel,'Execution');
                if isempty(namingRule)
                    namingRule='';
                end
            else
                namingRule=func.name;
            end

            name=slInternal('getIdentifierUsingNamingService',...
            modelname,namingRule,'step');
            if isempty(name)
                name=func.name;
            end
            fcnClsObj.setStepMethodName(name);

            if isempty(initName)

                namingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping...
                (hModel,'InitializeTerminate');
                if isempty(namingRule)
                    namingRule='';
                end
            else
                namingRule=initName;
            end

            tempInitName=slInternal('getIdentifierUsingNamingService',...
            modelname,namingRule,'initialize');
            if~isempty(tempInitName)
                initName=tempInitName;
            end

            fcnClsObj.setPropValue('InitFunctionName',initName);
            returnArgPresent=false;

            [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(hModel);
            usesCppMapping=strcmpi(mappingType,'CppModelMapping');

            if usesCppMapping
                className=mapping.CppClassReference.ClassName;
                if~isempty(className)
                    fcnClsObj.setClassName(className);
                else
                    fcnClsObj.setDefaultClassName();
                end
                classNamespace=mapping.CppClassReference.ClassNamespace;
                if~isempty(classNamespace)
                    fcnClsObj.setNamespace(classNamespace);
                end
            else
                fcnClsObj.setDefaultClassName();
            end

            if~isempty(func.returnArguments)&&~isempty(func.returnArguments{1}.mappedFrom)
                r=func.returnArguments{1};
                SLObjectName=Simulink.ID.getFullName([modelname,':',r.mappedFrom{1}]);
                portName=get_param(SLObjectName,'Name');

                fcnClsObj.Data(1).SLObjectName=portName;
                fcnClsObj.setArgQualifier(portName,char(r.qualifier));
                fcnClsObj.setArgCategory(portName,char(r.passBy));
                fcnClsObj.Data(1).ArgName=char(r.name);
                fcnClsObj.Data(1).PositionString='Return';
                fcnClsObj.Data(1).SLObjectType='Outport';

                name=SLObjectName;
                fcnClsObj.Data(1).PortNum=str2double(get_param(name,'Port'))-1;
                returnArgPresent=true;
            end

            for i=1:length(func.arguments)
                if(returnArgPresent)
                    index=i+1;
                else
                    index=i;
                end
                if isempty(func.arguments{i}.mappedFrom)
                    continue;
                end
                a=func.arguments{i};
                q=char(a.qualifier);
                if strcmpi(q,'ConstPointerToConstData')
                    q='const*const';
                elseif strcmpi(char(a.passBy),'Pointer')&&strcmpi(q,'Const')
                    q='const*';
                end
                SLObjectName=Simulink.ID.getFullName([modelname,':',a.mappedFrom{1}]);
                portName=get_param(SLObjectName,'Name');
                fcnClsObj.Data(index).SLObjectName=portName;
                fcnClsObj.setArgQualifier(portName,q)
                fcnClsObj.setArgCategory(portName,char(a.passBy));
                fcnClsObj.Data(index).ArgName=char(a.name);
                fcnClsObj.Data(index).Position=index;


                fcnClsObj.Data(index).PositionString=int2str(i);
                name=SLObjectName;

                portType=get_param(name,'BlockType');
                objectType='Outport';
                isInport=strcmpi(portType,'Inport');
                if coder.mapping.internal.StepFunctionMapping.isControlPort(portType)||isInport
                    objectType='Inport';
                end
                fcnClsObj.Data(index).SLObjectType=objectType;
            end


            fcnClsObj.Data=fcnClsObj.syncWithModel();
            updatedPrototype=coder.mapping.internal.StepFunctionMapping.getCppPrototypeFromRTWFcnClass(fcnClsObj,hModel);

            if~strcmpi(prototype,updatedPrototype)
                isCppEnabled=strcmp(mappingType,'CppModelMapping');
                if isCppEnabled&&~isempty(mapping.OutputFunctionMappings)
                    mapping.OutputFunctionMappings(1).Prototype=updatedPrototype;
                end
            end
            fcnClsObj.ArgSpecData=fcnClsObj.Data;
        end


        function prototype=getCppPrototypeFromRTWFcnClass(fcnClsObj,hModel)
            prototype='';
            if isempty(fcnClsObj)
                return;
            end


            if isprop(fcnClsObj,'Data')
                fcnClsObj.ArgSpecData=fcnClsObj.Data;
            end

            if isempty(fcnClsObj.ArgSpecData)
                prototype=[fcnClsObj.FunctionName,'( )'];
                return;
            end

            outportFound=false;

            modelName=getfullname(hModel);

            prototype=[fcnClsObj.FunctionName,'( '];

            for i=1:length(fcnClsObj.ArgSpecData)
                if strcmpi(fcnClsObj.ArgSpecData(i).Category,'Value')&&...
                    strcmp(fcnClsObj.ArgSpecData(i).SLObjectType,'Outport')

                    if~outportFound
                        try

                            SID=get_param([modelName,'/',fcnClsObj.ArgSpecData(i).SLObjectName],'SID');
                            prototype=[SID,' '...
                            ,fcnClsObj.ArgSpecData(i).ArgName,' = ',prototype];
                            outportFound=true;
                            continue;
                        catch me %#ok
                        end
                    else

                    end
                end

                try
                    qualifier='';
                    if strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const * const')
                        qualifier='const * const';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const')
                        qualifier='const';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const *')
                        qualifier='const *';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Category,'Pointer')
                        qualifier='*';
                    end
                    if strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const &')||...
                        (strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const')&&...
                        strcmpi(fcnClsObj.ArgSpecData(i).Category,'Reference'))
                        qualifier='const &';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Category,'Reference')
                        qualifier='&';
                    end

                    SID=get_param([modelName,'/',fcnClsObj.ArgSpecData(i).SLObjectName],'SID');

                    prototype=[prototype,qualifier,' '...
                    ,SID,' '...
                    ,fcnClsObj.ArgSpecData(i).ArgName,','];
                catch me %#ok
                end
            end
            if~outportFound

                prototype=['void ',prototype];
            end
            prototype(end)=')';
        end

        function prototype=syncPrototypeForCppCodeGen(modelHandle)
            prototype='';
            [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelHandle);
            isCppMappingEnabled=strcmp(mappingType,'CppModelMapping');

            fcnClsObj=get_param(modelHandle,'RTWCPPFcnClass');
            import coder.mapping.internal.*;

            if isempty(fcnClsObj)||~isCppMappingEnabled
                return;
            end

            if strcmpi(class(fcnClsObj),'RTW.ModelCPPArgsClass')

                prototype=StepFunctionMapping.getPrototypeFromRTWFcnClass(fcnClsObj,modelHandle);
            else

                prototype=fcnClsObj.getStepMethodName;
            end
        end

        function prototype=getPrototypeFromRTWFcnClass(fcnClsObj,hModel)
            prototype='';
            if isempty(fcnClsObj)
                return;
            end
            mmgr=get_param(hModel,'MappingManager');
            mapping=mmgr.getCurrentMapping;
            if isprop(fcnClsObj,'Data')
                fcnClsObj.ArgSpecData=fcnClsObj.Data;
            end

            if isempty(fcnClsObj.ArgSpecData)
                prototype=fcnClsObj.FunctionName;
                return;
            end

            [inpH,outpH]=coder.mapping.internal.StepFunctionMapping.getPortHandles(hModel);
            argMap=containers.Map;

            for i=1:length(inpH)
                portName=get_param(inpH(i),'Name');
                argMap(portName)='in';
            end

            for i=1:length(outpH)
                portName=get_param(outpH(i),'Name');
                argMap(portName)='out';
            end

            outportFound=false;

            modelName=getfullname(hModel);

            prototype=[fcnClsObj.FunctionName,'( '];

            for i=1:length(fcnClsObj.ArgSpecData)
                if strcmpi(fcnClsObj.ArgSpecData(i).Category,'Value')&&...
                    strcmp(fcnClsObj.ArgSpecData(i).SLObjectType,'Outport')

                    if~outportFound
                        if argMap.isKey(fcnClsObj.ArgSpecData(i).SLObjectName)

                            SID=get_param([modelName,'/',fcnClsObj.ArgSpecData(i).SLObjectName],'SID');
                            prototype=[SID,' '...
                            ,fcnClsObj.ArgSpecData(i).ArgName,' = ',prototype];
                            outportFound=true;
                            continue;
                        end
                    else

                    end
                end

                if argMap.isKey(fcnClsObj.ArgSpecData(i).SLObjectName)
                    qualifier='';
                    if strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const * const')
                        qualifier='const * const';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const')
                        qualifier='const';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const *')
                        qualifier='const *';
                    elseif strcmpi(fcnClsObj.ArgSpecData(i).Category,'Pointer')
                        qualifier='*';
                    end
                    if strcmpi(mapping,'CppModelMapping')
                        if strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const &')||...
                            (strcmpi(fcnClsObj.ArgSpecData(i).Qualifier,'const')&&...
                            strcmpi(fcnClsObj.ArgSpecData(i).Category,'Reference'))
                            qualifier='const &';
                        elseif strcmpi(fcnClsObj.ArgSpecData(i).Category,'Reference')
                            qualifier='&';
                        end
                    end

                    SID=get_param([modelName,'/',fcnClsObj.ArgSpecData(i).SLObjectName],'SID');

                    prototype=[prototype,qualifier,' '...
                    ,SID,' '...
                    ,fcnClsObj.ArgSpecData(i).ArgName,','];
                end
            end
            if~outportFound

                prototype=['void ',prototype];
            end
            prototype(end)=')';
        end

        function prototype=getPrototypefromLegacy(modelH)
            prototype='';
            packaging=get_param(modelH,'CodeInterfacePackaging');
            isCppClass=strcmpi(packaging,'C++ Class');
            if isCppClass
                fcnClsObj=get_param(modelH,'RTWCPPFcnClass');
            else
                fcnClsObj=get_param(modelH,'RTWFcnClass');
            end
            import coder.mapping.internal.*;
            if isempty(fcnClsObj)
                return;
            end

            if strcmpi(class(fcnClsObj),'RTW.ModelCPPArgsClass')

                fcnClsObj.ModelHandle=modelH;
                prototype=StepFunctionMapping.getCppPrototypeFromRTWFcnClass(fcnClsObj,modelH);
            elseif strcmpi(class(fcnClsObj),'RTW.ModelSpecificCPrototype')
                prototype=StepFunctionMapping.getPrototypeFromRTWFcnClass(fcnClsObj,modelH);
            end
        end


        function initName=getInitializeNameFromRTWFcnClass(modelH)
            fcnClsObj=get_param(modelH,'RTWFcnClass');
            initName='';
            if isempty(fcnClsObj)
                return;
            end

            if strcmpi(class(fcnClsObj),'RTW.ModelSpecificCPrototype')
                initName=fcnClsObj.getFunctionName('init');
            end
        end

        function prototypePresent=isStepFcnPrototypePresent(modelHandle)
            prototypePresent=false;
            mapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
            if~isempty(mapping)
                if~isempty(mapping.OutputFunctionMappings)

                    prototype=mapping.OutputFunctionMappings(1).Prototype;
                    if contains(prototype,["(",")","="])


                        prototypePresent=true;
                    end
                end
            end
        end
        function namePresent=isStepFcnNamePresent(modelHandle,isCppEnabled)
            namePresent=false;
            if isCppEnabled
                mapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
                if~isempty(mapping)
                    if~isempty(mapping.OutputFunctionMappings)

                        prototype=mapping.OutputFunctionMappings(1).Prototype;
                        if~isempty(prototype)&&~contains(prototype,["(",")","="])


                            namePresent=true;
                        end
                    end
                end
            end
        end

        function rtwFcnPrototype=parsePrototype(modelHandle)
            mapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
            prototypeString=mapping.OutputFunctionMappings(1).MappedTo.Prototype;

            func=coder.parser.Parser.doit(prototypeString);
            rtwFcnPrototype.StepFunctionName=func.name;
            rtwFcnPrototype.InitFunctionName=mapping.OneShotFunctionMappings(1).Prototype;
        end

        function namingRule=getNamingRuleFromMapping(modelHandle,type)

            namingRule='';
            mm=Simulink.CodeMapping.get(modelHandle,'CoderDictionary');
            if~isempty(mm)&&~isempty(mm.DefaultsMapping)
                fcnClassName=coder.api.internal.getFunctionDefaults(modelHandle,type,'FunctionClass');
                if~isequal(fcnClassName,...
                    DAStudio.message('coderdictionary:mapping:MappingFunctionDefault'))
                    hlp=coder.internal.CoderDataStaticAPI.getHelper();
                    dd=hlp.openDD(modelHandle);
                    fc=hlp.findEntry(dd,'FunctionClass',fcnClassName);
                    if~isempty(fc)
                        namingRule=hlp.getProp(fc,'FunctionName');
                    end
                end
            end
        end

        function[argName,qualifier,canArgBePassedByValue]=getPortDefaultConf(portH)

            argName=get_param(portH,'Name');
            argName=regexprep(argName,'[\s\\\/,\(\)\[\]\{\}]','_');
            argName=sprintf('arg_%s',argName);
            qualifier='pointer';
            canArgBePassedByValue=true;
            portType=get_param(portH,'BlockType');

            if strcmpi(portType,'EnablePort')||strcmpi(portType,'TriggerPort')...
                ||strcmpi(portType,'Inport')
                dimensions=[];

                hasBusObject=false;
                if strcmpi(portType,'EnablePort')||strcmpi(portType,'TriggerPort')

                    return;
                else
                    ph=get_param(portH,'PortHandles');
                    dimsPortH=ph.Outport;

                    useBusObject=get_param(portH,'UseBusObject');
                    if strcmp(useBusObject,'on')
                        hasBusObject=true;
                    end
                end

                if dimsPortH~=-1
                    dimensions=get_param(dimsPortH,'CompiledPortDimensions');
                end


                if~isempty(dimensions)&&~hasBusObject
                    qualifier='Value';
                    for index=2:length(dimensions)
                        if dimensions(index)>1
                            qualifier='pointer';
                            canArgBePassedByValue=false;
                            break;
                        end
                    end
                end
            end
        end

        function stepFcnName=getStepFcnName(hModel,prototype)
            func=coder.parser.Parser.doit(prototype);
            stepFcnName=coder.mapping.internal.StepFunctionUtils.getStepFcnName(hModel,func);
        end

        function initFcnName=getInitFcnName(modelHandle)
            mapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
            initFcnName=mapping.OneShotFunctionMappings(1).Prototype;
        end

        function numArgs=getNumArgs(prototype)
            func=coder.parser.Parser.doit(prototype);
            numArgs=coder.mapping.internal.StepFunctionUtils.getNumArgs(func);
        end

        function argName=getArgName(prototype,position)
            func=coder.parser.Parser.doit(prototype);
            argName=coder.mapping.internal.StepFunctionUtils.getArgName(func,position);
        end

        function qualifier=getQualifier(prototype,position)
            func=coder.parser.Parser.doit(prototype);
            qualifier=coder.mapping.internal.StepFunctionUtils.getQualifier(func,position);
        end

        function category=getCategory(prototype,position)
            func=coder.parser.Parser.doit(prototype);
            category=coder.mapping.internal.StepFunctionUtils.getCategory(func,position);
        end

        function name=getNameFromPosition(modelname,func,position)
            if~isempty(func.returnArguments)
                if position==1
                    name=Simulink.ID.getFullName([modelname,':',func.returnArguments{1}.mappedFrom{1}]);
                else
                    name=Simulink.ID.getFullName([modelname,':',func.arguments{position-1}.mappedFrom{1}]);
                end
            else
                name=Simulink.ID.getFullName([modelname,':',func.arguments{position}.mappedFrom{1}]);
            end
        end

        function type=getSLObjectType(modelHandle,prototype,position)
            func=coder.parser.Parser.doit(prototype);
            type=coder.mapping.internal.StepFunctionUtils.getSLObjectType(modelHandle,func,position);
        end

        function num=getPortNum(modelHandle,prototype,position)
            func=coder.parser.Parser.doit(prototype);
            num=coder.mapping.internal.StepFunctionUtils.getPortNum(modelHandle,func,position);
        end

        function inpH=getInportHandles(model)
            inpH=Simulink.findBlocks(model,'BlockType','Inport','Type','block',...
            Simulink.FindOptions('SearchDepth',1));
            enablePortH=Simulink.findBlocks(model,'BlockType','EnablePort','Type','block',...
            Simulink.FindOptions('SearchDepth',1));
            triggerPortH=Simulink.findBlocks(model,'BlockType','TriggerPort','Type','block',...
            Simulink.FindOptions('SearchDepth',1));
            if~isempty(enablePortH)
                inpH=[inpH;enablePortH];
            end
            if~isempty(triggerPortH)
                trigType=get_param(triggerPortH,'TriggerType');
                if~strcmpi(trigType,'function-call')
                    inpH=[inpH;triggerPortH];
                end
            end
        end


        function num=getCppPortNum(modelHandle,prototype,position)
            func=coder.parser.Parser.doit(prototype);
            num=coder.mapping.internal.StepFunctionUtils.getCppPortNum(modelHandle,func,position);
        end

        function[inpH,outpH]=getPortHandles(hModel)

            inpH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','Inport');
            outpH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','Outport');
            triggerH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','TriggerPort');
            enableH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','EnablePort');


            bepInpIndices=[];
            bepInpMap=containers.Map;
            for idx=1:length(inpH)
                if isequal(get(inpH(idx),'IsBusElement'),'on')
                    portName=get(inpH(idx),'PortName');
                    element=get(inpH(idx),'Element');
                    key=portName;
                    if~isempty(element)
                        key=[key,'.',element];%#ok<AGROW>
                    end
                    if isKey(bepInpMap,key)
                        bepInpIndices=[bepInpIndices,idx];%#ok<AGROW>
                    else
                        bepInpMap(key)='';
                    end
                end
            end
            inpH(bepInpIndices)=[];


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

        function updatedPrototype=addPortToMapping(prototype,blkPath)
            func=coder.parser.Parser.doit(prototype);
            updatedPrototype=prototype;

            if isempty(func.name)



                return;
            end

            if length(func.arguments)==1&&strcmp(func.arguments{1}.name,'CHECKED')...
                &&isempty(func.arguments{1}.mappedFrom)
                return;
            end

            if~isempty(func.arguments)
                updatedPrototype(end)=',';
                updatedPrototype=[updatedPrototype,' '];
            else
                updatedPrototype(end)=' ';
            end
            blockHandle=get_param(blkPath,'Handle');
            [argName,qualifier,~]=...
            coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(blockHandle);

            if strcmpi(qualifier,'pointer')
                updatedPrototype=[updatedPrototype,'* '];
            end
            sid=get_param(blkPath,'SID');
            updatedPrototype=[updatedPrototype,num2str(sid),' ',argName,')'];
        end

        function updatedPrototype=removePortFromMapping(prototype,blkPath)
            func=coder.parser.Parser.doit(prototype);
            updatedPrototype=prototype;
            sid=get_param(blkPath,'SID');
            if isempty(func.name)



                return;
            end

            if length(func.arguments)==1&&strcmp(func.arguments{1}.name,'CHECKED')...
                &&isempty(func.arguments{1}.mappedFrom)
                return;
            end

            if~isempty(func.returnArguments)&&~isempty(func.returnArguments{1}.mappedFrom)
                if strcmpi(func.returnArguments{1}.mappedFrom{1},num2str(sid))

                    updatedPrototype='void ';
                else
                    updatedPrototype=[func.returnArguments{1}.mappedFrom{1},' ',...
                    func.returnArguments{1}.name,' = '];
                end
            else
                updatedPrototype='void ';
            end

            updatedPrototype=[updatedPrototype,func.name,'( '];

            for i=1:length(func.arguments)
                if isempty(func.arguments{i}.mappedFrom)
                    continue;
                end
                if~strcmp(func.arguments{i}.mappedFrom{1},num2str(sid))
                    qualifier=func.arguments{i}.qualifier;
                    passBy=func.arguments{i}.passBy;

                    qualifierStr='';
                    if qualifier==coder.parser.Qualifier.Const&&...
                        passBy==coder.parser.PassByEnum.Value
                        qualifierStr='const';
                    elseif qualifier==coder.parser.Qualifier.Const&&...
                        passBy==coder.parser.PassByEnum.Pointer
                        qualifierStr='const *';
                    elseif qualifier==coder.parser.Qualifier.None&&...
                        passBy==coder.parser.PassByEnum.Pointer
                        qualifierStr=' *';
                    elseif qualifier==coder.parser.Qualifier.ConstPointerToConstData
                        qualifierStr='const * const';
                    end
                    updatedPrototype=[updatedPrototype,qualifierStr,...
                    ' ',func.arguments{i}.mappedFrom{1},' ',func.arguments{i}.name,','];
                end
            end
            updatedPrototype(end)=')';
        end

        function updatedPrototype=updateMapping(modelHandle,prototype)
            func=coder.parser.Parser.doit(prototype);
            updatedPrototype='';

            if isempty(func.name)



                return;
            end

            [inpH,outpH]=coder.mapping.internal.StepFunctionMapping.getPortHandles(modelHandle);
            argMap=containers.Map;

            for i=1:length(inpH)
                sid=get_param(inpH(i),'SID');
                argMap(num2str(sid))='in';
            end

            for i=1:length(outpH)
                sid=get_param(outpH(i),'SID');
                argMap(num2str(sid))='out';
            end

            updatedPrototype='void ';
            if~isempty(func.returnArguments)
                if~argMap.isKey(func.returnArguments{1}.mappedFrom{1})

                    func.returnArguments(1)=[];
                    updatedPrototype='void ';
                else
                    remove(argMap,{func.returnArguments{1}.mappedFrom{1}});
                    updatedPrototype=[func.returnArguments{1}.mappedFrom{1},' ',...
                    func.returnArguments{1}.name,' = '];
                end
            end


            updatedPrototype=[updatedPrototype,func.name,'( '];

            for i=1:length(func.arguments)
                if argMap.isKey(func.arguments{i}.mappedFrom{1})
                    remove(argMap,{func.arguments{i}.mappedFrom{1}});
                    qualifier=func.arguments{i}.qualifier;
                    passBy=func.arguments{i}.passBy;

                    qualifierStr='';
                    if qualifier==coder.parser.Qualifier.Const&&...
                        passBy==coder.parser.PassByEnum.Value
                        qualifierStr='const';
                    elseif qualifier==coder.parser.Qualifier.Const&&...
                        passBy==coder.parser.PassByEnum.Pointer
                        qualifierStr='const *';
                    elseif qualifier==coder.parser.Qualifier.None&&...
                        passBy==coder.parser.PassByEnum.Pointer
                        qualifierStr=' *';
                    elseif qualifier==coder.parser.Qualifier.ConstPointerToConstData
                        qualifierStr='const * const';
                    end
                    updatedPrototype=[updatedPrototype,qualifierStr,...
                    ' ',func.arguments{i}.mappedFrom{1},' ',func.arguments{i}.name,','];
                end
            end

            modelname=get_param(modelHandle,'Name');

            remainingPorts=keys(argMap);
            for i=1:length(remainingPorts)
                sid=remainingPorts{i};
                blockHandle=Simulink.ID.getHandle([modelname,':',sid]);
                [argName,qualifier,~]=...
                coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(blockHandle);
                if strcmpi(qualifier,'pointer')
                    updatedPrototype=[updatedPrototype,' * '];
                end
                updatedPrototype=[updatedPrototype,num2str(sid),' ',argName,','];
            end
            updatedPrototype(end)=')';
        end

        function previewStr=getFunctionPreview(model,mapObj)
            previewStr='';
            [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            isCppEnabled=strcmp(mappingType,'CppModelMapping');
            isBaseRateFcn=false;
            if startsWith(mapObj.SimulinkFunctionName,'Step')
                dollarN='step';
                tidStr=regexp(mapObj.SimulinkFunctionName,'Step(\d+)','tokens');
                if isempty(tidStr)||strcmp(tidStr{1}{1},'0')
                    isBaseRateFcn=true;
                end
            elseif startsWith(mapObj.SimulinkFunctionName,'Output')
                dollarN='output';
                tidStr=regexp(mapObj.SimulinkFunctionName,'Output(\d+)','tokens');
                if isempty(tidStr)||strcmp(tidStr{1}{1},'0')
                    isBaseRateFcn=true;
                end
            end
            if isBaseRateFcn


                if coder.mapping.internal.StepFunctionMapping.isStepFcnPrototypePresent(model)

                    func=coder.parser.Parser.doit(mapObj.Prototype);


                    if~isempty(func.returnArguments)

                        returnStr=[func.returnArguments{1}.name,' = '];
                    else
                        returnStr='void ';
                    end


                    fcnNamingRule=mapObj.getCodeFunctionName();
                    if isempty(fcnNamingRule)
                        fcnNamingRule=coder.mapping.internal.StepFunctionMapping.getNamingRuleFromMapping(...
                        model,'Execution');
                        if isempty(fcnNamingRule)
                            fcnNamingRule='$R$N';
                        end
                    end
                    assert(~isempty(fcnNamingRule));
                    fcnNameStr=slInternal('getIdentifierUsingNamingService',...
                    model,fcnNamingRule,dollarN);


                    argStr='';
                    comma='';
                    isMdlrefMulti=strcmp(get_param(model,'ModelReferenceNumInstancesAllowed'),'Multi');
                    isTopMulti=strcmp(get_param(model,'CodeInterfacePackaging'),'Reusable function');
                    multiInstanceId='';
                    if isMdlrefMulti&&isTopMulti
                        multiInstanceId='* self';
                    else
                        if isMdlrefMulti||isTopMulti
                            multiInstanceId='[* self]';
                        end
                    end
                    if strcmp(mappingType,'CoderDictionary')
                        deploymentType=mapping.DeploymentType;
                        isComponent=strcmp(deploymentType,'Component');
                        isSubcomponent=strcmp(deploymentType,'Subcomponent');
                        if isComponent
                            if isTopMulti
                                multiInstanceId='* self';
                            else
                                multiInstanceId='';
                            end
                        elseif(isSubcomponent)
                            if isMdlrefMulti
                                multiInstanceId='* self';
                            else
                                multiInstanceId='';
                            end
                        end
                    end
                    if isCppEnabled
                        multiInstanceId='';
                    end
                    if~isempty(multiInstanceId)
                        argStr=[argStr,multiInstanceId];
                        comma=', ';
                    end





                    for argIdx=1:length(func.arguments)
                        arg=func.arguments{argIdx};

                        if strcmp(arg.qualifier,'None')
                            isConst=false;
                        else
                            isConst=true;
                        end
                        isPointer=false;
                        isReference=false;
                        if strcmp(arg.passBy,'Pointer')
                            isPointer=true;
                        elseif strcmp(arg.passBy,'Reference')
                            isReference=true;
                        else
                            isPointer=false;
                            isReference=false;
                        end

                        if isReference&&~isPointer
                            if isConst
                                qualifier='const & ';
                            else
                                qualifier='& ';
                            end
                        else
                            if strcmp(arg.qualifier,'ConstPointerToConstData')
                                qualifier='const * const ';
                            elseif isConst&&isPointer
                                qualifier='const * ';
                            elseif isConst&&~isPointer
                                qualifier='const ';
                            elseif~isConst&&isPointer
                                qualifier='* ';
                            else
                                qualifier='';
                            end
                        end
                        argNameStr=arg.name;

                        if argIdx<length(func.arguments)&&strcmp(arg.name,func.arguments{argIdx+1}.name)
                            continue;
                        end
                        argStr=[argStr,comma,qualifier,argNameStr];

                        comma=', ';
                    end

                    previewStr=[returnStr,fcnNameStr,'(',argStr,')'];
                end
            end

        end

    end
end






