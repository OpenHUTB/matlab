


classdef SubsystemFunctionControlUI<handle
    properties
URL
ModelHandle
BlockHandle
        SubScriptions={};
Dlg
ID
        DlgPosition=[100,100,550,600]
SimulinkFunctionPrototype

Mapping
CurrentMappingName
ListenerMap
MappingCache
    end
    methods
        function obj=SubsystemFunctionControlUI(modelH,blockH)
            obj.ModelHandle=modelH;
            obj.BlockHandle=blockH;
            connector.ensureServiceOn;
            [~,~,fcnName]=coder.dictionary.internal.SubsystemFunctionMapping.getFcnInOutArgs(obj.BlockHandle);
            obj.SimulinkFunctionPrototype.FunctionName=fcnName;
            obj.ID=sprintf('/FunctionPrototypeControl/%f/%s',modelH,fcnName);
            obj.URL=connector.getBaseUrl(['/toolbox/coder/simulinkcoder_app/slfpc/web/SlFpcDlgView/index.html?',obj.ID]);
            obj.ListenerMap=containers.Map;
        end
        function subsysFcnChanged(obj,~,eventData)

            if strcmp(eventData.EventName,'CoderDictionarySubsysFcnEntityAdded')||...
                strcmp(eventData.EventName,'CoderDictionarySubsysFcnMappingEntityDeleted')
                obj.ListenerMap('updated')=[];
                obj.ListenerMap('updated')=...
                event.listener(obj.Mapping.SubsystemFunctions,'CoderDictionarySubsysFcnMappingEntityUpdated',...
                @obj.subsysFcnChanged);
            end
            if strcmp(eventData.EventName,'CoderDictionarySubsysFcnMappingEntityDeleted')
                obj.MappingCache=[];
                simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
            end
            if strcmp(eventData.EventName,'CoderDictionarySubsysFcnMappingEntityUpdated')
                if obj.updateMappingCache

                    obj.refreshUI();
                end
            end
        end
        function isCacheUpdated=updateMappingCache(obj)
            isCacheUpdated=false;
            tmp=coder.dictionary.api.get(...
            get_param(obj.ModelHandle,'name'),...
            'SimulinkFunction',obj.SimulinkFunctionPrototype.FunctionName);
            if~strcmp(tmp.CodePrototype,obj.MappingCache.CodePrototype)||...
                tmp.UseDefaultNamingRule~=obj.MappingCache.UseDefaultNamingRule
                isCacheUpdated=true;
                obj.MappingCache=tmp;
            end
        end
        function receive(obj,msg)
            if strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'ready'
                    obj.handleReadyMessage();
                case{'setPrototype','applyDialog'}

                    previewStr=strrep(msg.Prototype.previewStr,[obj.getOptionalMultiInstanceIdentifier,','],'');
                    previewStr=strrep(previewStr,'$M','_');


                    result=simulinkcoder.internal.slfpc.FunctionControlUI.hasInvalidIdentifier(previewStr);
                    if~result.hasInvalidIdentifier
                        try
                            obj.setPrototype(msg.Prototype);
                            if strcmp(msg.Value,'setPrototype')
                                simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
                            end


                            if strcmp(msg.Value,'applyDialog')
                                obj.refreshListener;
                            end
                            message.publish(obj.ID,struct('MessageID','update_success'));
                        catch me
                            obj.handleError(me);
                        end
                    else

                        if strcmp(result.InvalidIdentifier,'FunctionName')
                            obj.sendInvalidIdentifierMsg(result.InvalidIdentifier,result.InvalidIdentifierStr);
                        else

                            obj.sendInvalidIdentifierMsg(result.InvalidIdentifier-1,result.InvalidIdentifierStr);
                        end
                    end
                case 'cancelDialog'
                    simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
                case 'view_identifier_format_rule'
                    cs=getActiveConfigSet(obj.ModelHandle);

                    configset.highlightParameter(cs,{'CustomSymbolStrFcnArg'});
                case 'identifierOnChange'
                    obj.handleIdentifierChange(msg);
                case 'helpDialog'

                    helpview(fullfile(docroot,'ecoder','helptargets.map'),'ecoder_config_slfcn_code_interface');
                end
            end
        end
        function sendInvalidIdentifierMsg(obj,idNum,idDisplay)
            if ischar(idNum)&&strcmp(idNum,'FunctionName')
                widgetId='fcnName-widget';
                argId='';
            else
                widgetId=sprintf('%d-symbol-textbox',idNum);
                argId=idNum;
            end
            msg.widgetId=widgetId;
            msg.argId=argId;
            msg.MessageID='displayInvalidIdentifierMsg';
            msg.errorMsg=message('SimulinkCoderApp:slfpc:ResolvedIdentifierIsInvalid').getString;
            msg.identifierDisplayStr=idDisplay;
            message.publish(obj.ID,msg);
        end
        function refreshListener(obj)
            obj.removeListener;
            obj.addListener;
        end
        function removeListener(obj)
            obj.ListenerMap=containers.Map;
        end
        function addListener(obj)


            return;

            obj.Mapping=simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.getMapping(obj.ModelHandle);
            if~isempty(obj.Mapping)
                obj.ListenerMap('added')=event.listener(obj.Mapping,'CoderDictionarySubsysFcnMappingEntityAdded',@obj.subsysFcnChanged);
                obj.ListenerMap('deleted')=event.listener(obj.Mapping,'CoderDictionarySubsysFcnMappingEntityDeleted',@obj.subsysFcnChanged);
                obj.ListenerMap('updated')=event.listener(obj.Mapping.SubsystemFunctions,'CoderDictionarySubsysFcnMappingEntityUpdated',@obj.subsysFcnChanged);
            else
                mmgr=get_param(obj.ModelHandle,'MappingManager');
                obj.ListenerMap('MapMgr')=event.listener(mmgr,'CoderDictionaryMappingActivated',@obj.mapActivatedCallback);
            end
        end
        function mapActivatedCallback(obj,~,~)
            obj.addListener;
            obj.Mapping=simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.getMapping(obj.ModelHandle);
            if isempty(obj.CurrentMappingName)
                obj.CurrentMappingName=obj.Mapping.Name;
            else

                if~strcmp(obj.CurrentMappingName,obj.Mapping.Name)
                    obj.MappingCache=[];
                    simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
                end
            end
            if~isempty(obj.Mapping)
                obj.ListenerMap('MapSync')=event.listener(obj.Mapping,'CoderDictionaryMappingSynced',@obj.mapSyncedCallback);
            end
        end
        function mapSyncedCallback(obj,~,~)
            obj.addListener;
        end
        function out=getPrototype(obj)
            out='';
            sr=slroot;
            if~sr.isValidSlObject(obj.BlockHandle)
                return;
            end
            [ins,outs,~]=coder.dictionary.internal.SubsystemFunctionMapping.getFcnInOutArgs(obj.BlockHandle);
            fcnName=obj.SimulinkFunctionPrototype.FunctionName;
            inOuts=intersect(ins,outs);
            ins=setdiff(ins,inOuts);
            outs=setdiff(outs,inOuts);


            mapping.CodePrototype=[outs{1},' = ',fcnName,'(',ins{1},')'];
            mapping.Name=fcnName;
            mapping.UseDefaultNamingRule=false;
            obj.MappingCache=mapping;
            obj.addListener;
            prototype=mapping.CodePrototype;


            argMap=containers.Map;
            argConfigsetSymbol=get_param(obj.ModelHandle,'CustomSymbolStrFcnArg');
            arguments=loc_createArgumentStructArray(length(ins)+length(outs));
            for i=1:length(ins)
                arguments(i).name=ins{i};
                arguments(i).inOut='in';
                arguments(i).qualifier='none';
                arguments(i).symbol='';
                arguments(i).displayStr='';
                arguments(i).configsetDisplayStr='';
                arguments(i).configsetSymbol='';
                arguments(i).isReturnArg=false;
                arguments(i).canArgBePassedByValue=true;
                argMap(ins{i})=arguments(i);
            end
            nIns=length(ins);



            if~isempty(outs)

                for i=1:length(outs)
                    arguments(i+nIns).name=outs{i};
                    arguments(i+nIns).inOut='out';
                    arguments(i+nIns).qualifier='pointer';
                    arguments(i+nIns).symbol='';
                    arguments(i+nIns).displayStr='';
                    arguments(i+nIns).configsetDisplayStr='';
                    arguments(i+nIns).configsetSymbol='';
                    arguments(i+nIns).isReturnArg=false;
                    arguments(i+nIns).canArgBePassedByValue=true;
                    argMap(outs{i})=arguments(i+nIns);
                end
            end
            nOuts=length(outs);
            for i=1:length(inOuts)
                arguments(i+nIns+nOuts).name=inOuts{i};
                arguments(i+nIns+nOuts).inOut='inout';
                arguments(i+nIns+nOuts).qualifier='pointer';
                arguments(i+nIns+nOuts).symbol='';
                arguments(i+nIns+nOuts).displayStr='';
                arguments(i+nIns+nOuts).configsetDisplayStr='';
                arguments(i+nIns+nOuts).configsetSymbol='';
                arguments(i+nIns+nOuts).isReturnArg=false;
                argMap(inOuts{i})=arguments(i+nIns+nOuts);
            end



            if~isempty(prototype)
                args=coder.parser.Parser.doit(prototype);
                arguments=loc_createArgumentStructArray(length(args.arguments)+length(args.returnArguments));


                for i=1:length(args.arguments)
                    [name,symbol]=obj.getNameAndSymbol(args.arguments{i},mapping.UseDefaultNamingRule);
                    arguments(i).name=name;
                    arguments(i).symbol=symbol;
                    if argMap.isKey(name)
                        arguments(i).inOut=argMap(name).inOut;
                        arguments(i).canArgBePassedByValue=argMap(name).canArgBePassedByValue;
                    else
                        arguments(i).inOut='in';
                        arguments(i).canArgBePassedByValue=true;
                    end
                    tmp=obj.getArgIdentifier(symbol,name,arguments(i).inOut);
                    arguments(i).displayStr=tmp.displayStr;
                    tmp=obj.getArgIdentifier(argConfigsetSymbol,name,arguments(i).inOut);
                    arguments(i).configsetDisplayStr=tmp.displayStr;
                    arguments(i).configsetSymbol=argConfigsetSymbol;
                    if~strcmp(arguments(i).inOut,'in')


                        qualifier='pointer';
                    else
                        if strcmp(args.arguments{i}.qualifier,'None')
                            isConst=false;
                        else
                            isConst=true;
                        end
                        if~strcmp(args.arguments{i}.passBy,'Value')
                            isPointer=true;
                        else
                            isPointer=false;
                        end
                        if isConst&&isPointer
                            qualifier='const-pointer';
                        elseif isConst&&~isPointer
                            qualifier='const';
                        elseif~isConst&&isPointer
                            qualifier='pointer';
                        else
                            qualifier='none';
                        end
                    end
                    arguments(i).qualifier=strtrim(qualifier);
                    arguments(i).isReturnArg=false;
                end

                if~isempty(args.returnArguments)
                    i=length(args.arguments)+1;
                    [name,symbol]=obj.getNameAndSymbol(args.returnArguments{1},mapping.UseDefaultNamingRule);
                    arguments(i).name=name;
                    arguments(i).symbol=symbol;
                    if argMap.isKey(name)
                        arguments(i).inOut=argMap(name).inOut;
                    else
                        arguments(i).inOut='in';
                    end
                    tmp=obj.getArgIdentifier(symbol,name,arguments(i).inOut);
                    arguments(i).displayStr=tmp.displayStr;
                    tmp=obj.getArgIdentifier(argConfigsetSymbol,name,arguments(i).inOut);
                    arguments(i).configsetDisplayStr=tmp.displayStr;
                    arguments(i).configsetSymbol=argConfigsetSymbol;
                    arguments(i).qualifier='';
                    arguments(i).isReturnArg=true;
                end



                slArgNames=loc_union(loc_union(ins,outs),inOuts);
                if~isequal(slArgNames,unique({arguments.name}))
                    disp('error')
                end
            else
                args.name=fcnName;
            end
            out.Arguments=arguments;
            symbol=args.name;
            out.FunctionName=obj.getFcnNameIdentifier(symbol,fcnName,mapping.UseDefaultNamingRule);
            out.OverrideNamingRule=~mapping.UseDefaultNamingRule;

            out.HeaderFile=[get_param(obj.ModelHandle,'name'),'.h'];
        end



        function[name,symbol]=getNameAndSymbol(obj,arg,useDefaultNamingRule)
            if useDefaultNamingRule
                symbol=get_param(obj.ModelHandle,'CustomSymbolStrFcnArg');
            else
                symbol=arg.name;
            end
            if isempty(arg.mappedFrom)
                name=arg.name;
            else
                if iscell(arg.mappedFrom)
                    name=arg.mappedFrom{1};
                else
                    name=arg.mappedFrom;
                end
            end
        end
        function out=getFcnNameIdentifier(obj,symbol,object,useDefaultNamingRule)
            modelName=get_param(obj.ModelHandle,'name');
            error='';
            displayStr=symbol;
            isValidIdentifier=true;




            [configsetDisplayStr,configsetSymbol]=coder.dictionary.internal.SubsystemFunctionMapping.getFcnName(...
            obj.BlockHandle,object,symbol);
            if useDefaultNamingRule
                symbol=configsetSymbol;
            end
            if isempty(symbol)
                error=message('SimulinkCoderApp:slfpc:InvalidIdentifier').getString;
                isValidIdentifier=false;
            else
                try
                    displayStr=coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnFcnName(...
                    modelName,object,symbol);
                catch me
                    error=me.message;
                    isValidIdentifier=false;
                end
            end
            out=struct('name',object,'symbol',symbol,'displayStr',displayStr,...
            'error',error,'inOut','','isValidIdentifier',isValidIdentifier,...
            'configsetSymbol',configsetSymbol,'configsetDisplayStr',configsetDisplayStr);
        end
        function out=getArgIdentifier(obj,symbol,object,inOut)
            modelName=get_param(obj.ModelHandle,'name');
            error='';
            displayStr=symbol;
            isValidIdentifier=true;
            if isempty(symbol)
                error=message('SimulinkCoderApp:slfpc:InvalidIdentifier').getString;
                isValidIdentifier=false;
            else
                try
                    displayStr=coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnArgName(...
                    modelName,object,symbol,inOut);


                    if length(symbol)>1&&strcmp(symbol(1:2),'$M')
                        displayStr=['$M',displayStr];
                    end
                catch me
                    error=me.message;
                    isValidIdentifier=false;
                end
            end
            out=struct('name',object,'symbol',symbol,'displayStr',displayStr,...
            'error',error,'inOut',inOut,'isValidIdentifier',isValidIdentifier);
        end
        function setPrototype(obj,prototype)
            fcnName=obj.SimulinkFunctionPrototype.FunctionName;
            newValue.CodePrototype=prototype.prototypeStr;
            newValue.UseDefaultNamingRule=~prototype.overrideNamingRule;
            slfeature('RTWCGSubsysReturnByValue',1);
            slsvTestingHook('TestSubsysFcnFPC',1);
            set_param(get_param(obj.ModelHandle,'name'),'Dirty','on');










        end
        function msg=getPrototypeMessage(obj)
            try
                msg=obj.getPrototype;
            catch me

                simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
                obj.handleError(me);
            end

            msg.supportDefaultNamingRule=true;


            msg.supportArgRenaming=true;
            msg.supportFcnNameRenaming=true;


            msg.OverrideNamingRule=true;
            multiInstanceIdentifier='';
            msg.supportMultiInstance=true;
            msg.isDefinedInMdlref=false;
            msg.multiInstanceIdentifier=multiInstanceIdentifier;


            msg.SubsystemFcnPrototype='Subsystem(In1, Out1)';
        end
        function refreshUI(obj)

            msg=obj.getPrototypeMessage;
            msg.MessageID='refreshUI';
            msg.AlertMessage=message('SimulinkCoderApp:slfpc:RefreshMsg').getString;
            message.publish(obj.ID,msg);
        end
        function handleReadyMessage(obj)
            sr=slroot;
            if sr.isValidSlObject(obj.BlockHandle)
                msg=obj.getPrototypeMessage;
                msg.MessageID='initPrototypes';
                message.publish(obj.ID,msg);
            else

                simulinkcoder.internal.app.SubsystemFunctionControlUI.closeCallBack(obj);
            end
        end
        function handleError(obj,e)
            stageName=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceFor',obj.SimulinkFunctionPrototype.FunctionName).getString;
            myStage=Simulink.output.Stage(stageName,'ModelName',get_param(obj.ModelHandle,'name'),...
            'UIMode',true);
            Simulink.output.error(e);
            myStage.delete;
        end
        function handleIdentifierChange(obj,msg)
            object=msg.Identifier;
            if strcmp(object.type,'fcnName')


                useDefaultNamingRule=false;
                identifier=obj.getFcnNameIdentifier(object.symbol,object.name,useDefaultNamingRule);
            else
                identifier=obj.getArgIdentifier(object.symbol,object.name,object.inOut);

                if isempty(identifier.error)
                    try
                        coder.mapping.internal.SimulinkFunctionMapping.validateFunctionPrototype(...
                        get_param(obj.ModelHandle,'name'),...
                        obj.SimulinkFunctionPrototype.FunctionName,...
                        msg.Prototype.prototypeStr,false);
                    catch me
                        switch me.identifier
                        case 'coderdictionary:api:UniqueCodeArguments'
                            identifier.error=me.message;
                        end
                    end
                end
            end
            msg.Identifier=identifier;
            msg.MessageID=['response_',msg.Value];
            message.publish(obj.ID,msg);
        end

        function delete(obj)
            if~isempty(obj.Dlg)
                simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack(obj);
                delete(obj.Dlg);
                obj.Dlg=[];
            end
        end
        function show(obj)
            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.Position=obj.DlgPosition;
            end
            if isempty(obj.SubScriptions)
                obj.SubScriptions{end+1}=message.subscribe(obj.ID,@obj.receive);
            end
            p=obj.Dlg.position;

            obj.Dlg.showNormal;
            obj.Dlg.show;
            obj.Dlg.position=p;
        end
        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.DialogTitle=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceFor',obj.SimulinkFunctionPrototype.FunctionName).getString;
            dlgstruct.CloseCallback='simulinkcoder.internal.slfpc.SubsystemFunctionControlUI.closeCallBack';
            dlgstruct.CloseArgs={obj};


            item.Url=connector.applyNonce(obj.URL);
            item.DisableContextMenu=true;
            item.EnableInspectorOnLoad=false;
            item.Type='webbrowser';
            item.WebKit=true;
            item.MinimumSize=[450,300];
            item.Tag='Tag_FunctionPrototypeControl_Browser';

            dlgstruct.Items={item};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs='';
            dlgstruct.MinMaxButtons=true;
            buttonSet={''};
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;
            dlgstruct.DispatcherEvents={};
        end
    end
    methods(Static=true,Hidden=true)
        function closeCallBack(obj)
            for i=1:length(obj.SubScriptions)
                message.unsubscribe(obj.SubScriptions{i});
            end
            simulinkcoder.internal.slfpc.FunctionControlDialogManager.removeDialog(...
            obj.ModelHandle,obj.SimulinkFunctionPrototype.FunctionName);
            delete(obj.Dlg);
            obj.Dlg=[];
        end
        function out=isPrototypeSame(newValue,oldValue)
            out=false;
            if newValue.UseDefaultNamingRule==oldValue.UseDefaultNamingRule
                newArgs=coder.parser.Parser.doit(newValue.CodePrototype);
                oldArgs=coder.parser.Parser.doit(oldValue.CodePrototype);
                if isequal(newArgs,oldArgs)
                    out=true;
                end
            end
        end


        function out=hasInvalidIdentifier(str)
            out.hasInvalidIdentifier=false;
            out.InvalidIdentifier='';
            out.InvalidIdentifierStr='';
            args=coder.parser.Parser.doit(str);

            if~coder.mapping.internal.SimulinkFunctionMapping.isValidIdentifier(args.name)
                out.hasInvalidIdentifier=true;
                out.InvalidIdentifier='FunctionName';
                out.InvalidIdentifierStr=args.name;
                return;
            end
            for i=1:length(args.arguments)

                if~coder.mapping.internal.SimulinkFunctionMapping.isValidIdentifier(args.arguments{i}.name)
                    out.hasInvalidIdentifier=true;
                    out.InvalidIdentifier=i;
                    out.InvalidIdentifierStr=args.arguments{i}.name;
                    return;
                end
            end
        end

        function out=isValidIdentifier(str)
            out=false;
            if isempty(str)
                return;
            end
            tmp=regexprep(str,'[^a-zA-Z_0-9]','_');
            if strcmp(tmp,str)

                firstChar=str(1);
                if(firstChar<'0'||firstChar>'9')

                    out=true;
                end
            end
        end
        function out=getMapping(modelH)

            mmgr=get_param(modelH,'MappingManager');
            Simulink.CoderDictionary.ModelMapping;
            out=mmgr.getActiveMappingFor('CoderDictionary');
        end
        function out=getOptionalMultiInstanceIdentifier()
            out='[* self]';
        end
        function out=getMultiInstanceIdentifier()
            out='* self';
        end
        function fcnBlk=getLocalFunctionBlockFromCaller(blk)

            fcnBlk=[];

            if strcmp(get_param(blk,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blk,'SystemType'),'SimulinkFunction')
                fcnBlk=getfullname(blk);
                return;
            end
            if~(strcmp(get_param(blk,'BlockType'),'FunctionCaller'))
                return;
            end

            fcns=Simulink.FunctionGraphCatalog(get_param(blk,'Handle'));


            callerPrototype=get_param(blk,'FunctionPrototype');
            fcnHdl=[];
            for cntB=1:length(fcns)
                if(strcmp(fcns(cntB).prototypes,callerPrototype))
                    fcnHdl=fcns(cntB).handle;
                    break;
                end
            end
            if~isempty(fcnHdl)
                fcnBlk=[get_param(fcnHdl,'Parent'),'/',get_param(fcnHdl,'Name')];

                if(strcmp(get_param(fcnBlk,'BlockType'),'ModelReference'))
                    fcnBlk=[];
                end
            end
        end
    end
end

function out=loc_union(A,B)


    if isempty(A)
        out=B;
    elseif isempty(B)
        out=A;
    else
        out=union(A,B);
    end
end

function out=loc_createArgumentStructArray(num)
    out=repmat(struct('name',{},...
    'inOut',{},...
    'qualifier',{},...
    'symbol',{},...
    'displayStr',{},...
    'configsetDisplayStr',{},...
    'configsetSymbol',{},...
    'canArgBePassedByValue',{},...
    'isReturnArg',{}),num,1);
end


