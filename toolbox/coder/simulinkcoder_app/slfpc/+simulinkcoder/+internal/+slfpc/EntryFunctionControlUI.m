




classdef EntryFunctionControlUI<handle
    properties
URL
ModelHandle
ModelName
FunctionType
FunctionId
RegistryId
        SubScriptions={};
Dlg
ID
        DlgPosition=[100,100,600,325]
ModelMapping
MappingObject
CurrentMappingName
SimulinkFcnListenerMap
        IsCppClass=false;





        debug=false;
    end
    methods
        function obj=EntryFunctionControlUI(modelH,mapping,functionType,functionId,debug)
            obj.ModelHandle=modelH;
            obj.ModelName=getfullname(modelH);
            obj.MappingObject=mapping;
            obj.FunctionType=functionType;
            obj.FunctionId=functionId;

            hasMapping=~isempty(mapping);
            if hasMapping
                validId=Simulink.CodeMapping.getValidIdentifierForDialogId(mapping,functionType,functionId);
                try

                    obj.ModelMapping=simulinkcoder.internal.slfpc.EntryFunctionControlUI.getModelMapping(obj.ModelHandle);
                catch me
                    obj.handleError(me);
                    return;
                end
            else


                validId=functionId;
                obj.ModelMapping='';
            end
            obj.RegistryId=sprintf('$%s_%s$',functionType,validId);
            if nargin>=5
                obj.debug=debug;
            end
            connector.ensureServiceOn;
            obj.ID=sprintf('/FunctionPrototypeControl/%f/%s',modelH,obj.RegistryId);
            obj.URL=connector.applyNonce(connector.getBaseUrl(['/toolbox/coder/simulinkcoder_app/slfpc/web/SlFpcDlgView/index.html?',obj.ID]));
            obj.SimulinkFcnListenerMap=containers.Map;
            if(strcmp(get_param(modelH,"CodeInterfacePackaging"),"C++ class"))
                obj.IsCppClass=true;
            else
                obj.IsCppClass=false;
            end
        end

        function result=validateAndMaybeSetMappingPrototyope(obj,msg)
            prototypeStr=msg.Prototype.prototypeStr;


            result=simulinkcoder.internal.slfpc.EntryFunctionControlUI.hasInvalidIdentifier(prototypeStr);
            if~result.hasInvalidIdentifier
                obj.setPrototype(prototypeStr);
                if strcmp(msg.Value,'setPrototype')
                    simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack(obj);
                end
            else

                obj.sendInvalidIdentifierMsg(result.InvalidIdentifier,result.InvalidIdentifierStr);
            end
        end

        function receive(obj,msg)
            if strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'ready'
                    obj.handleReadyMessage();
                case 'default'
                    obj.handleGetDefault();
                case 'validate'
                    validateAndMaybeSetMappingPrototyope(obj,msg);
                    msg.Failed=false;
                    msg.iconLocation=fullfile('images','icons','task_passed.png');
                    currentMappingType=simulinkcoder.internal.slfpc.EntryFunctionControlUI.getCurrentModelMapping(obj.ModelHandle);
                    try
                        if strcmpi(currentMappingType,'CppModelMapping')
                            [status,errMsg]=coder.dictionary.internal.runCppValidation(obj.ModelHandle);
                            if~status
                                throwAsCaller(MSLException([],message('RTW:fcnClass:finish',errMsg)));
                            end
                        else
                            coder.dictionary.internal.runValidation(obj.ModelHandle);
                        end
                    catch me
                        obj.handleError(me);
                        msg.Failed=true;
                        msg.iconLocation=fullfile('images','icons','task_failed.png');
                        msg.Message=me.message;
                    end
                    msg.MessageID='validationComplete';
                    message.publish(obj.ID,msg);
                case{'setPrototype','applyDialog'}
                    result=validateAndMaybeSetMappingPrototyope(obj,msg);

                    if result.hasInvalidIdentifier
                        return;
                    end

                    if strcmp(msg.Value,'setPrototype')
                        simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack(obj);
                    end


                    message.publish(obj.ID,struct('MessageID','update_success'));
                case 'cancelDialog'
                    simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack(obj);
                case 'view_identifier_format_rule'
                    cs=getActiveConfigSet(obj.ModelHandle);

                    configset.highlightParameter(cs,{'CustomSymbolStrFcnArg'});
                case 'identifierOnChange'
                    obj.handleIdentifierChange(msg);
                case 'helpDialog'
                    if obj.IsCppClass
                        helpview(fullfile(docroot,'ecoder','helptargets.map'),'cpp_config_dialog_step')
                    else
                        helpview(fullfile(docroot,'ecoder','helptargets.map'),'ecoder_func_proto_control');
                    end
                end
            end
        end

        function sendInvalidIdentifierMsg(obj,idNum,idDisplay)
            if ischar(idNum)&&strcmp(idNum,'FunctionName')
                widgetId='fcnName-widget';
                argId='';
            elseif isnumeric(idNum)
                widgetId=sprintf('%d-symbol-textbox',idNum);
                argId=idNum;
            else
                error('Unexpected id');
            end
            msg.widgetId=widgetId;
            msg.argId=argId;
            msg.MessageID='displayInvalidIdentifierMsg';
            msg.errorMsg=message('SimulinkCoderApp:slfpc:ResolvedIdentifierIsInvalid').getString;
            msg.identifierDisplayStr=idDisplay;
            message.publish(obj.ID,msg);
        end

        function addListener(obj)
            mmgr=get_param(obj.ModelHandle,'MappingManager');
            obj.SimulinkFcnListenerMap('MapMgr')=event.listener(mmgr,'CoderDictionaryMappingActivated',@obj.mapActivatedCallback);
        end

        function mapActivatedCallback(obj,~,~)

            obj.ModelMapping=simulinkcoder.internal.slfpc.FunctionControlUI.getModelMapping(obj.ModelHandle);
            if isempty(obj.CurrentMappingName)
                obj.CurrentMappingName=obj.ModelMapping.Name;
            else

                if~strcmp(obj.CurrentMappingName,obj.ModelMapping.Name)
                    obj.MappingCache=[];
                    simulinkcoder.internal.slfpc.FunctionControlUI.closeCallBack(obj);
                end
            end

            obj.SimulinkFcnListenerMap('MapSync')=event.listener(obj.ModelMapping,'CoderDictionaryMappingSynced',@obj.mapSyncedCallback);
        end

        function mapSyncedCallback(obj,~,~)

            obj.addListener;
        end

        function out=getPrototype(obj)
            out='';

            dirty=get_param(obj.ModelName,'Dirty');

            fcnName='';
            prototype='';

            obj.addListener;
            currentMappingType=simulinkcoder.internal.slfpc.EntryFunctionControlUI.getCurrentModelMapping(obj.ModelHandle);
            isFunctionThatSupportsArgs=false;
            if~isempty(obj.MappingObject)&&~isempty(obj.MappingObject.Prototype)...
                &&(strcmp(currentMappingType,'CoderDictionary')||...
                strcmp(currentMappingType,'CppModelMapping'))
                prototype=obj.MappingObject.Prototype;
                fcnName=prototype;
                isFunctionThatSupportsArgs=(isequal(obj.FunctionType,'Step')&&...
                (isequal(obj.MappingObject.SimulinkFunctionName,'Step')||...
                isequal(obj.MappingObject.SimulinkFunctionName,'Step0')))...
                ||(isequal(obj.FunctionType,'Output')&&...
                (isequal(obj.MappingObject.SimulinkFunctionName,'Output')||...
                isequal(obj.MappingObject.SimulinkFunctionName,'Output0')));
            elseif isempty(obj.MappingObject)
                fcnClsObj=get_param(obj.ModelName,'RTWFcnClass');
                if~isempty(fcnClsObj)&&~strcmpi(class(fcnClsObj),'RTW.FcnDefault')
                    isFunctionThatSupportsArgs=true;
                    prototype=coder.mapping.internal.StepFunctionMapping.getPrototypeFromRTWFcnClass(fcnClsObj,obj.ModelHandle);
                end
            end

            arguments=[];

            out.PrototypePresent=false;

            if isFunctionThatSupportsArgs&&contains(prototype,["(",")","="])
                args=coder.parser.Parser.doit(prototype);

                if~isempty(args)&&~isempty(args.name)
                    fcnName=args.name;
                    if strcmpi(fcnName,'USE_DEFAULT_FROM_FUNCTION_CLASSES')


                        fcnName='';
                    end
                end

                if~isempty(args)&&~isempty(args.name)&&(~isempty(args.arguments)||~isempty(args.returnArguments))
                    obj.Dlg.Position=[100,100,600,725];



                    [ins,outs]=coder.mapping.internal.StepFunctionMapping.getPortHandles(obj.ModelHandle);

                    inOuts=intersect(ins,outs);
                    ins=setdiff(ins,inOuts);
                    outs=setdiff(outs,inOuts);


                    argMap=containers.Map;
                    arguments=loc_createArgumentStructArray(length(ins)+length(outs)+length(inOuts));
                    for i=1:length(ins)
                        name=get_param(ins(i),'name');
                        [argName,qualifier,canArgBePassedByValue]=...
                        coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(ins(i));
                        arguments(i).name=argName;
                        arguments(i).SID=get_param(ins(i),'SID');
                        arguments(i).portName=name;
                        arguments(i).inOut='in';
                        arguments(i).qualifier=qualifier;
                        arguments(i).portType='Inport';
                        arguments(i).isReturnArg=false;
                        arguments(i).canArgBePassedByValue=canArgBePassedByValue;
                        arguments(i).position=i;
                        argMap(arguments(i).SID)=arguments(i);
                    end
                    nIns=length(arguments);

                    for i=1:length(outs)
                        name=get_param(outs(i),'name');
                        [argName,qualifier,canArgBePassedByValue]=...
                        coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(outs(i));
                        arguments(i+nIns).name=argName;
                        arguments(i+nIns).SID=get_param(outs(i),'SID');
                        arguments(i+nIns).portName=name;
                        arguments(i+nIns).inOut='out';
                        arguments(i+nIns).qualifier=qualifier;
                        arguments(i+nIns).portType='Outport';
                        arguments(i+nIns).isReturnArg=false;
                        arguments(i+nIns).canArgBePassedByValue=canArgBePassedByValue;
                        arguments(i+nIns).position=i+nIns;
                        argMap(arguments(i+nIns).SID)=arguments(i+nIns);
                    end

                    args=coder.parser.Parser.doit(prototype);


                    for i=1:length(args.arguments)
                        if isempty(args.arguments{i}.mappedFrom)

                            continue;
                        end
                        prototypeSID=args.arguments{i}.mappedFrom{1};
                        if argMap.isKey(prototypeSID)
                            position=argMap(prototypeSID).position;
                            arguments(position).name=args.arguments{i}.name;

                            if~strcmp(arguments(position).inOut,'in')&&...
                                ~strcmp(currentMappingType,'CppModelMapping')


                                qualifier='pointer';
                            else
                                if strcmp(args.arguments{i}.qualifier,'Const')
                                    isConst=true;
                                else
                                    isConst=false;
                                end
                                isPointer=false;
                                isReference=false;
                                if strcmp(args.arguments{i}.passBy,'Reference')
                                    isReference=true;
                                elseif strcmp(args.arguments{i}.passBy,'Pointer')
                                    isPointer=true;
                                end
                                if isReference&&~isPointer
                                    if isConst
                                        qualifier='const-reference';
                                    else
                                        qualifier='reference';
                                    end
                                else
                                    if strcmp(args.arguments{i}.qualifier,'ConstPointerToConstData')
                                        qualifier='const-pointer-const';
                                    elseif isConst&&isPointer
                                        qualifier='const-pointer';
                                    elseif isConst&&~isPointer
                                        qualifier='const';
                                    elseif~isConst&&isPointer
                                        qualifier='pointer';
                                    else
                                        qualifier='none';
                                    end
                                end
                            end
                            arguments(position).qualifier=strtrim(qualifier);
                            arguments(position).position=i;
                        end
                    end


                    if~isempty(args.returnArguments)&&~isempty(args.returnArguments{1}.mappedFrom)

                        prototypeSID=args.returnArguments{1}.mappedFrom{1};

                        if argMap.isKey(prototypeSID)
                            position=argMap(prototypeSID).position;
                            arguments(position).name=args.returnArguments{1}.name;
                            arguments(position).isReturnArg=true;
                            arguments(position).qualifier='';
                        end
                    end
                    out.PrototypePresent=true;
                end
            end


            set_param(obj.ModelName,'Dirty',dirty);

            out.Arguments=arguments;
            out.FunctionName=obj.getFcnNameIdentifier(fcnName);
        end

        function out=getDefaultArguments(obj)
            [ins,outs]=coder.mapping.internal.StepFunctionMapping.getPortHandles(obj.ModelHandle);

            portH=[ins;outs];
            out=[];

            if isempty(portH)
                out.Arguments=[];
                return;
            end

            simStatus=get_param(obj.ModelHandle,'SimulationStatus');

            compileObj=coder.internal.CompileModel;

            if~strcmpi(simStatus,'paused')&&~strcmpi(simStatus,'initializing')&&...
                ~strcmpi(simStatus,'running')
                try
                    if strcmpi(get_param(obj.ModelHandle,'SimulationMode'),'accelerator')
                        throw(MSLException([],message('RTW:fcnClass:accelSimForbiddenForFPC')));
                    end
                    lastWarnSaved=lastwarn;
                    lastwarn('');

                    compileObj.compile(obj.ModelHandle);

                    if~isempty(lastwarn)
                        disp([DAStudio.message('RTW:fcnClass:fcnProtoCtlWarn'),lastwarn]);
                    end
                    lastwarn(lastWarnSaved);
                catch ex
                    msg.message=DAStudio.message('RTW:fcnClass:modelNotCompile',ex.message);
                    exception=MSLException([],'RTW:fcnClass:modelNotCompile','%s',msg.message);
                    obj.handleError(exception);
                    for i=1:length(ex.cause)
                        if~strcmp(ex.cause{i}.identifier,'Simulink:Engine:EI_CannotCompleteEI')
                            obj.handleError(ex.cause{i});
                        end
                    end
                    return;
                end
            end

            arguments=loc_createArgumentStructArray(length(ins)+length(outs));
            for i=1:length(ins)
                name=get_param(ins(i),'name');
                [argName,qualifier,canArgBePassedByValue]=...
                coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(ins(i));
                arguments(i).name=argName;
                arguments(i).SID=get_param(ins(i),'SID');
                arguments(i).portName=name;
                arguments(i).inOut='in';
                arguments(i).qualifier=qualifier;
                arguments(i).portType='Inport';
                arguments(i).isReturnArg=false;
                arguments(i).canArgBePassedByValue=canArgBePassedByValue;
                arguments(i).position=i;
            end
            nIns=length(ins);

            for i=1:length(outs)
                name=get_param(outs(i),'name');
                [argName,qualifier,canArgBePassedByValue]=...
                coder.mapping.internal.StepFunctionMapping.getPortDefaultConf(outs(i));
                arguments(i+nIns).name=argName;
                arguments(i+nIns).SID=get_param(outs(i),'SID');
                arguments(i+nIns).portName=name;
                arguments(i+nIns).inOut='out';
                arguments(i+nIns).qualifier=qualifier;
                arguments(i+nIns).portType='Outport';
                arguments(i+nIns).isReturnArg=false;
                arguments(i+nIns).canArgBePassedByValue=canArgBePassedByValue;
                arguments(i+nIns).position=i+nIns;
            end

            out.Arguments=arguments;
        end

        function out=getFcnNameIdentifier(obj,name)



            if~isempty(name)
                fcnName=name;
            else
                fcnName=Simulink.CodeMapping.getResolvedFunctionName(obj.MappingObject,obj.ModelHandle,obj.getFunctionCategoryForUI());
            end

            error='';
            isValidIdentifier=true;

            if~isempty(name)
                isValidIdentifier=simulinkcoder.internal.slfpc.EntryFunctionControlUI.isValidIdentifier(name);

                if~isValidIdentifier
                    error=message('SimulinkCoderApp:slfpc:InvalidIdentifier').getString;
                end
            end

            out=struct('name',name,'placeholder',fcnName,...
            'error',error,'isValidIdentifier',isValidIdentifier);
        end

        function out=getArgIdentifier(~,object,inOut)
            error='';
            isValidIdentifier=simulinkcoder.internal.slfpc.EntryFunctionControlUI.isValidIdentifier(object,true,false,false);

            if~isValidIdentifier
                error=message('SimulinkCoderApp:slfpc:InvalidIdentifier').getString;
            end

            out=struct('name',object,...
            'error',error,'inOut',inOut,'isValidIdentifier',isValidIdentifier);
        end

        function setPrototype(obj,prototypeStr)
            func=coder.parser.Parser.doit(prototypeStr);
            mappingObject=obj.MappingObject;
            if~isempty(mappingObject)
                currentPrototypeStr=mappingObject.Prototype;
                if~isempty(func)&&isempty(func.arguments)&&isempty(func.returnArguments)
                    if~simulinkcoder.internal.slfpc.EntryFunctionControlUI.isPrototypeSame(currentPrototypeStr,func.name)
                        mappingObject.Prototype=func.name;
                        set_param(obj.ModelHandle,'Dirty','on');
                    end
                else
                    if~simulinkcoder.internal.slfpc.EntryFunctionControlUI.isPrototypeSame(currentPrototypeStr,prototypeStr)
                        mappingObject.Prototype=prototypeStr;
                        set_param(obj.ModelHandle,'Dirty','on');
                    end
                end
            end
        end

        function msg=getPrototypeMessage(obj)
            try
                msg=obj.getPrototype;
                msg.isFPC=true;
                multiInstanceId='';
                isMdlrefMulti=strcmp(get_param(obj.ModelHandle,'ModelReferenceNumInstancesAllowed'),'Multi');
                isTopMulti=strcmp(get_param(obj.ModelHandle,'CodeInterfacePackaging'),'Reusable function');
                isMdlrefZero=strcmp(get_param(obj.ModelHandle,'ModelReferenceNumInstancesAllowed'),'Zero');
                if(isMdlrefMulti||isMdlrefZero)&&isTopMulti
                    multiInstanceId='* self';
                else
                    if isMdlrefMulti||isTopMulti
                        multiInstanceId='[* self]';
                    end
                end
                currentMappingType=simulinkcoder.internal.slfpc.EntryFunctionControlUI.getCurrentModelMapping(obj.ModelHandle);
                if strcmp(currentMappingType,'CoderDictionary')
                    if strcmp(obj.ModelMapping.DeploymentType,"Component")
                        if isTopMulti
                            multiInstanceId='* self';
                        else
                            multiInstanceId='void';
                        end
                    elseif strcmp(obj.ModelMapping.DeploymentType,"Subcomponent")
                        if isMdlrefMulti
                            multiInstanceId='* self';
                        else
                            multiInstanceId='';
                        end
                    end
                end
                if strcmp(currentMappingType,'CppModelMapping')
                    multiInstanceId='';
                end
                msg.supportMultiInstance=isMdlrefMulti||isTopMulti;
                msg.multiInstanceIdentifier=multiInstanceId;
            catch me

                simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack(obj);
                obj.handleError(me);
            end
        end

        function refreshUI(obj)

            msg=obj.getPrototypeMessage;
            msg.MessageID='refreshUI';
            msg.AlertMessage=message('SimulinkCoderApp:slfpc:RefreshMsg').getString;
            message.publish(obj.ID,msg);
        end

        function handleReadyMessage(obj)
            msg=obj.getPrototypeMessage;
            msg.labels=obj.getLabelStrings();
            msg.canConfigureArguments=obj.canConfigureArguments();
            msg.canConfigureFcnName=obj.canConfigureFcnName();

            msg.iconInfoLocation=fullfile(matlabroot,'toolbox','rtw','rtw','@RTW','@FcnCtlUI','icons','icon_info.png');
            msg.MessageID='initPrototypes';

            targetLang=get_param(obj.ModelHandle,'TargetLang');
            msg.targetLang=targetLang;


            codeInterfacePackaging=get_param(obj.ModelHandle,'CodeInterfacePackaging');
            msg.codeInterfacePackaging=codeInterfacePackaging;

            message.publish(obj.ID,msg);
        end

        function handleError(obj,e)
            stageName=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceFor',obj.ModelName).getString;
            myStage=Simulink.output.Stage(stageName,'ModelName',get_param(obj.ModelHandle,'name'),...
            'UIMode',true);
            Simulink.output.error(e);
            myStage.delete;
        end

        function handleIdentifierChange(obj,msg)
            object=msg.Identifier;
            if strcmp(object.type,'fcnName')
                identifier=obj.getFcnNameIdentifier(object.name);
            else
                identifier=obj.getArgIdentifier(object.name,object.inOut);
            end
            msg.Identifier=identifier;
            msg.MessageID=['response_',msg.Value];
            message.publish(obj.ID,msg);
        end

        function handleGetDefault(obj)
            msg=obj.getDefaultArguments;
            msg.MessageID='response_defaultArguments';
            message.publish(obj.ID,msg);
            if isfield(msg,'Arguments')
                obj.Dlg.Position(3)=600;
                obj.Dlg.Position(4)=725;
            end
        end

        function delete(obj)
            if~isempty(obj.Dlg)
                simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack(obj);
                delete(obj.Dlg);
                obj.Dlg=[];
            end
        end

        function show(obj)
            if isempty(obj.SubScriptions)
                obj.SubScriptions{end+1}=message.subscribe(obj.ID,@obj.receive);
            end

            if obj.debug
                disp(strrep(obj.URL,'index.html','index-debug.html'));
                return;
            end
            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.Position=obj.DlgPosition;
            end

            p=obj.Dlg.position;
            if~obj.canConfigureArguments
                p(3)=600;
                p(4)=230;
            end

            obj.Dlg.showNormal;
            obj.Dlg.show;
            obj.Dlg.position=p;
        end

        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.DialogTitle=obj.getDialogTitle;
            dlgstruct.CloseCallback='simulinkcoder.internal.slfpc.EntryFunctionControlUI.closeCallBack';
            dlgstruct.CloseArgs={obj};


            item.Url=obj.URL;
            item.DisableContextMenu=true;
            item.EnableInspectorOnLoad=false;
            item.Type='webbrowser';
            item.WebKit=true;
            item.Tag='Tag_FunctionPrototypeControl_Browser';
            item.MinimumSize=[450,0];

            dlgstruct.Items={item};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs='';
            dlgstruct.MinMaxButtons=true;
            buttonSet={''};
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;
            dlgstruct.DispatcherEvents={};
        end

        function out=isHarness(obj)
            out=strcmp(get_param(obj.ModelHandle,'IsHarness'),'on');
        end
        function out=canConfigureFcnName(obj)
            if obj.isHarness
                out=false;
            else
                out=true;
            end
        end
        function out=canConfigureArguments(obj)
            switch obj.FunctionType
            case{'Step','Output','subsystem_step'}

                assert(~(strcmp(obj.FunctionType,'subsystem_step')...
                &&~isempty(obj.ModelMapping)...
                &&isa(obj.ModelMapping,'Simulink.CoderDictionary.ModelMapping')...
                &&obj.ModelMapping.isFunctionPlatform));

                if isempty(obj.FunctionId)||strcmp(obj.FunctionId,'0')
                    if~isempty(obj.ModelMapping)...
                        &&isa(obj.ModelMapping,'Simulink.CoderDictionary.ModelMapping')...
                        &&obj.ModelMapping.isFunctionPlatform...
                        &&strcmp(obj.ModelMapping.DeploymentType,"Component")
                        out=false;
                    else
                        out=true;
                    end
                else
                    out=false;
                end
            otherwise
                out=false;
            end
        end

        function out=getDollarNForFunction(obj)
            switch obj.FunctionType
            case{'Step','subsystem_step'}
                out=strcat('step',obj.FunctionId);
            case 'Output'
                out=strcat('output',obj.FunctionId);
            case 'Update'
                out=strcat('update',obj.FunctionId);
            case{'Initialize','subsystem_initialize'}
                out='initialize';
            case 'Terminate'
                out='terminate';
            case 'Reset'
                out=obj.FunctionId;
            case 'FcnCallInport'
                out=obj.FunctionId;
            otherwise
                error('Unknown function type');
            end
        end

        function out=getFunctionCategoryForUI(obj)
            switch obj.FunctionType
            case{'Step','Output'}
                out='OutputFunctionMappings';
            case 'Update'
                out='UpdateFunctionMappings';
            case 'Reset'
                out='ResetFunctions';
            case 'FcnCallInport'
                out='FcnCallInports';
            case{'Initialize','Terminate'}
                out='OneShotFunctionMappings';
            case 'subsystem_step'
                error('needs to be handled');
            case 'subsystem_initialize'
                error('needs to be handled');
            otherwise
                error('Unknown function type');
            end
        end


        function out=getDialogTitle(obj)
            labels=obj.getLabelStrings;
            out=labels.DialogTitle;
        end

        function labels=getLabelStrings(obj)
            targetLang=get_param(obj.ModelHandle,'TargetLang');

            labels.FunctionNameLabel='';
            labels.FunctionNameLabelTooltip='';
            labels.DialogTitle='';
            labels.Description='';
            labels.FunctionLabel='';
            labels.PreviewLabelTooltip=message('SimulinkCoderApp:slfpc:CodePresentationTooltip').getString;
            labels.PreviewLabel=message('SimulinkCoderApp:slfpc:CCodePresentationLabel',targetLang).getString+":";
            labels.FcnNameTextboxTooltip=message('SimulinkCoderApp:slfpc:FcnNameTooltip').getString;
            switch obj.FunctionType
            case{'Step','Output','Update'}
                if isempty(obj.FunctionId)
                    labels.FunctionLabel=message('SimulinkCoderApp:slfpc:FunctionLabel',targetLang,obj.FunctionType).getString;
                else
                    labels.FunctionLabel=message('SimulinkCoderApp:slfpc:PeriodicFunctionLabelWithTid',...
                    targetLang,obj.FunctionType,num2str(obj.MappingObject.Period)).getString;
                end
                labels.Description=message('SimulinkCoderApp:slfpc:CControlDialogDescription',targetLang).getString;
            case{'Initialize','Terminate'}
                labels.FunctionLabel=message('SimulinkCoderApp:slfpc:FunctionLabel',targetLang,obj.FunctionType).getString;
            case 'Reset'
                labels.FunctionLabel=message('SimulinkCoderApp:slfpc:ResetFunctionLabel',targetLang,obj.FunctionId).getString;
            case 'FcnCallInport'
                labels.FunctionLabel=message('SimulinkCoderApp:slfpc:ExportedFunctionWithBlockName',targetLang,obj.FunctionId).getString;
            case 'subsystem_initialize'
                labels.FunctionLabel=message('SimulinkCoderApp:slfpc:FunctionLabel',targetLang,'Initialize').getString;
                labels.DialogTitle=message('SimulinkCoderApp:slfpc:ConfigureInterfaceFor',obj.ModelName,...
                message('SimulinkCoderApp:slfpc:SubsystemCFunction',targetLang).getString).getString;
            case 'subsystem_step'
                labels.FunctionLabel=message('SimulinkCoderApp:slfpc:FunctionLabel',targetLang,'Step').getString;
                labels.DialogTitle=message('SimulinkCoderApp:slfpc:ConfigureInterfaceFor',obj.ModelName,...
                message('SimulinkCoderApp:slfpc:SubsystemCFunction',targetLang).getString).getString;
            end

            labels.FunctionNameLabel=message('SimulinkCoderApp:slfpc:FcnNameLabel',labels.FunctionLabel).getString+":";

            if isempty(labels.DialogTitle)
                labels.DialogTitle=message('SimulinkCoderApp:slfpc:ConfigureInterfaceFor',obj.ModelName,labels.FunctionLabel).getString;
            end

            if isempty(labels.Description)
                labels.Description=message('SimulinkCoderApp:slfpc:FPCDialogDescription',labels.FunctionLabel).getString;
            end
            if isempty(labels.FunctionNameLabelTooltip)
                labels.FunctionNameLabelTooltip=message('SimulinkCoderApp:slfpc:FcnNameLabel',labels.FunctionLabel).getString;
            end
        end
    end
    methods(Static=true,Hidden=true)
        function closeCallBack(obj)
            for i=1:length(obj.SubScriptions)
                message.unsubscribe(obj.SubScriptions{i});
            end
            simulinkcoder.internal.slfpc.FunctionControlDialogManager.removeDialog(...
            obj.ModelHandle,obj.RegistryId);
            delete(obj.Dlg);
            obj.Dlg=[];
        end
        function out=isPrototypeSame(newValue,oldValue)
            out=false;
            newArgs=coder.parser.Parser.doit(newValue);
            oldArgs=coder.parser.Parser.doit(oldValue);
            if isequal(newArgs,oldArgs)
                out=true;
            end
        end


        function out=hasInvalidIdentifier(str)
            out.hasInvalidIdentifier=false;
            out.InvalidIdentifier='';
            out.InvalidIdentifierStr='';
            if~isempty(str)
                args=coder.parser.Parser.doit(str);
                if~simulinkcoder.internal.slfpc.EntryFunctionControlUI.isValidIdentifier(args.name)
                    out.hasInvalidIdentifier=true;
                    out.InvalidIdentifier='FunctionName';
                    out.InvalidIdentifierStr=args.name;
                    return;
                end

                for i=1:length(args.arguments)
                    if~simulinkcoder.internal.slfpc.EntryFunctionControlUI.isValidIdentifier(args.arguments{i}.name,true,false,false)
                        out.hasInvalidIdentifier=true;
                        out.InvalidIdentifier=i-1;
                        out.InvalidIdentifierStr=args.arguments{i}.name;
                        return;
                    end
                end
            end
        end















        function out=isValidIdentifier(str,varargin)
            out=true;
            isEmptyInvalid=false;
            isDollarMValid=true;
            areTokensAllowed=true;
            if nargin>1
                isEmptyInvalid=varargin{1};
            end
            if nargin>2
                isDollarMValid=varargin{2};
            end
            if nargin>3
                areTokensAllowed=varargin{3};
            end
            if isempty(str)
                if isEmptyInvalid
                    out=false;
                else
                    out=true;
                end
                return;
            end

            if~areTokensAllowed
                tmp=regexprep(str,'[^a-zA-Z_0-9]','_');
                if~strcmp(tmp,str)


                    out=false;
                    return;
                else
                    firstChar=str(1);
                    if(firstChar>='0'&&firstChar<='9')

                        out=false;
                        return;
                    end
                end
            end


            validDecorators={'[u]','[u_]','[l]','[l_]','[uL]',...
            '[uL_]','[lU]','[U]','[U_]','[L]','[L_]'};
            extractedDecorators=regexp(str,'\[.*?\]','match');
            for decorator=extractedDecorators
                if~any(strcmp(decorator{1},validDecorators))
                    out=false;
                    return;
                end
            end


            validTokens={'$R','$N','$U'};
            if isDollarMValid
                validTokens{end+1}='$M';
            end
            extractedTokens=regexp(str,'\$.+?','match');
            tokensMap=containers.Map;
            for token=extractedTokens
                if~any(strcmp(token{1},validTokens))
                    out=false;
                    return;
                end

                if tokensMap.isKey(token{1})
                    out=false;
                    return;
                end
                tokensMap(token{1})='';
            end



            repFcnName=regexprep(str,'\[.*?\]|\$.+?','a');

            if strcmp(repFcnName(1),'_')
                repFcnName(1)='a';
            end

            tempConfigEntry=RTW.FcnArgSpec;
            tempConfigEntry.ArgName=repFcnName;
            if~tempConfigEntry.isValidIdentifier()
                out=false;
                return;
            end
            reservedChars={'auto','break','case','char','const','continue',...
            'default','do','double','else','enum','extern',...
            'float','for','goto','if','int','long','register',...
            'return','short','signed','sizeof','static','struct',...
            'switch','typedef','union','unsigned','void','volatile',...
            'while'};
            temp=ismember(reservedChars,str);
            pos=find(temp,1);
            if~isempty(pos)
                out=false;
                return;
            end
        end

        function out=getCurrentModelMapping(modelH)

            mmgr=get_param(modelH,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            Simulink.CppModelMapping.ModelMapping;
            out=mmgr.getCurrentMapping();
        end

        function out=getModelMapping(modelH)
            mmgr=get_param(modelH,'MappingManager');

            activeMapping=simulinkcoder.internal.slfpc.EntryFunctionControlUI.getCurrentModelMapping(modelH);
            out=mmgr.getActiveMappingFor(activeMapping);
        end

    end
end

function out=loc_createArgumentStructArray(num)
    out=repmat(struct('name',{},...
    'portName',{},...
    'inOut',{},...
    'qualifier',{},...
    'portType',{},...
    'canArgBePassedByValue',{},...
    'isReturnArg',{}),num,1);
end




