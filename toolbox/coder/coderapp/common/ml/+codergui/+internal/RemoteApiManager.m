

classdef(Sealed)RemoteApiManager<handle



    properties(Constant,Access=private)
        MANAGE_REQUEST='remoteApi/manage/send'
        MANAGE_REPLY='remoteApi/manage/receive'
        BUSY_CHANGE_INBOUND='remoteApi/busyChange'
        INVOKE_TRIGGER_OUTBOUND='remoteApi/invoke/request'
        INVOKE_RETURN_INBOUND='remoteApi/invoke/reply'
        HANDLE_CLEANUP_OUTBOUND='remoteApi/runHandleCleanup/request'
        HANDLE_CLEANUP_INBOUND='remoteApi/runHandleCleanup/reply'
        CALLBACK_TRIGGERED_INBOUND='remoteApi/handleRemoteCallback'
    end

    properties(SetAccess=immutable)
Root
    end

    properties(GetAccess=private,SetAccess=immutable)
Client
IdleTimeout
InvocationTimeout
    end

    properties(Access=private)
        Subscriptions={}
        Busy=false
        InvocationIdCounter=uint64(0)
InvocationResults
        CallbackIdCounter=uint64(0)
Callbacks
ApiDocs
    end

    methods
        function this=RemoteApiManager(client,varargin)
            validateattributes(client,{'codergui.WebClient'},{'scalar'});

            ip=inputParser();
            ip.addParameter('ApiDocSources',{},@(c)ischar(c)||iscellstr(c));%#ok<ISCLSTR>
            ip.addParameter('IdleTimeout',120,@isnumeric);
            ip.addParameter('InvocationTimeout',120,@isnumeric);
            ip.parse(varargin{:});

            this.Client=client;
            this.IdleTimeout=ip.Results.IdleTimeout;
            this.InvocationTimeout=ip.Results.InvocationTimeout;

            this.Root=codergui.internal.RemoteApiNode(this);
            this.InvocationResults=containers.Map('KeyType','uint64','ValueType','any');
            this.Callbacks=containers.Map('KeyType','uint64','ValueType','any');
            this.ApiDocs=this.loadApiDocs(ip.Results.ApiDocSources,this.Client.Debug);

            this.init();
        end
    end

    methods
        function varargout=invoke(this,methodPath,varargin)
            methodPath=this.validatePathArg(methodPath);
            if numel(methodPath)>1
                node=this.getNode(methodPath(1:end-1));
            else
                node=this.getNode();
            end
            if nargout>0
                varargout={this.invokeRemoteMethod(node,methodPath{end},varargin);};
            else
                this.invokeRemoteMethod(node,methodPath{end},varargin);
            end
        end

        function node=getNode(this,varargin)
            if nargin>2
                path=varargin;
            elseif nargin>1
                path=varargin{1};
            else
                node=this.Root;
                return;
            end
            path=this.validatePathArg(path);

            node=this.Root;
            for i=1:numel(path)
                token=path{i};
                if isempty(token)
                    break;
                else
                    node=node.x_getChild(token);
                    assert(~isempty(node),'Could not find node at path "%s"',...
                    strjoin(path(1:i),'.'));
                end
            end
        end

        function delete(this)
            if isvalid(this)&&~isempty(this.Subscriptions)
                this.Client.unsubscribe(this.Subscriptions);
            end
        end
    end

    methods(Access={?codergui.internal.RemoteApiNode,?codergui.internal.RemoteApiManager})
        function[output,hadOutput]=invokeRemoteMethod(this,node,methodName,args)
            output=[];
            hadOutput=false;

            this.clientWaitFor(@()~this.Busy,'Timeout',this.IdleTimeout);
            if this.Client.Disposed
                return;
            end

            invocationId=this.markInvocation();
            invocationCleanup=onCleanup(@()this.InvocationResults.remove(invocationId));

            this.Client.publish(this.INVOKE_TRIGGER_OUTBOUND,struct(...
            'invocationId',invocationId,...
            'nodePath',{node.x_BasePath},...
            'methodName',methodName,...
            'args',{this.prepareArguments(args)}...
            ));
            this.clientWaitFor(@()~isempty(this.InvocationResults(invocationId)),'Interval',0.12);
            if this.Client.Disposed
                return;
            end

            result=this.InvocationResults(invocationId);
            if isfield(result,'error')&&~isempty(result.error)
                this.opaqueError(methodName,result.error);





            end
            if isfield(result,'returnValue')
                output=this.convertInboundValue(result.returnValue);
                hadOutput=true;
            end
        end

        function str=printMethodInfo(this,node,methodName)
            qualName=strjoin([node.x_BasePath,methodName],'.');
            if isempty(this.ApiDocs)||~this.ApiDocs.isKey(qualName)
                str=qualName;
                return;
            end
            apiDoc=this.ApiDocs(qualName);

            if isfield(apiDoc,'returnType')
                if iscell(apiDoc.returnType)
                    returnTypeStr=strjoin(apiDoc.returnType,'|');
                else
                    returnTypeStr=apiDoc.returnType;
                end
            else
                returnTypeStr='void';
            end
            if isfield(apiDoc,'parameters')&&~isempty(apiDoc.parameters)
                if iscell(apiDoc.parameters)
                    processor=@cellfun;
                else
                    processor=@arrayfun;
                end
                paramStr=strjoin(processor(@(p)this.printParameterInfo(p),...
                apiDoc.parameters,'UniformOutput',false),', ');
            else
                paramStr='';
            end
            if isfield(apiDoc,'description')&&~isempty(apiDoc.description)
                descStr=sprintf('\t-\t%s',apiDoc.description);
            else
                descStr='';
            end

            str=sprintf('%s <strong>%s</strong>(%s)%s',returnTypeStr,methodName,paramStr,descStr);
        end
    end

    methods(Access=private)
        function init(this)
            this.Subscriptions={...
            this.Client.subscribe(this.MANAGE_REQUEST,...
            @(msg)this.handleManageRequest(msg))...
            ,this.Client.subscribe(this.BUSY_CHANGE_INBOUND,...
            @(msg)this.handleBusyChange(msg))...
            ,this.Client.subscribe(this.INVOKE_RETURN_INBOUND,...
            @(msg)this.handleInvocationReturn(msg))...
            ,this.Client.subscribe(this.CALLBACK_TRIGGERED_INBOUND,...
            @(msg)this.handleRemoteCallback(msg))...
            };
        end

        function converted=prepareArguments(this,args)
            converted=cell(size(args));
            for i=1:numel(args)
                arg=args{i};
                if isa(arg,'function_handle')
                    type='callback';
                    converted{i}.callbackId=this.registerRemoteCallback(arg);
                elseif isempty(arg)&&~iscell(arg)
                    type='null';
                else
                    type='other';
                    converted{i}.value=arg;
                end
                converted{i}.argType=type;
            end
        end

        function value=convertInboundValue(this,valueStruct)
            value=[];
            switch valueStruct.type
            case 'cleanupHandle'
                value=onCleanup(@()this.runHandleCleanup(valueStruct.handleId));
            case 'null'
            case 'undefined'
            otherwise
                if isfield(valueStruct,'value')
                    value=valueStruct.value;
                end
            end
        end

        function cbId=registerRemoteCallback(this,funcHandle)
            keys=this.Callbacks.keys();
            for i=1:numel(keys)
                cb=this.Callbacks(keys{i});
                if isequal(cb,funcHandle)
                    cbId=keys{i};
                    return;
                end
            end
            this.CallbackIdCounter=this.CallbackIdCounter+1;
            cbId=this.CallbackIdCounter;
            this.Callbacks(cbId)=funcHandle;
        end

        function deleteRemoteCallbacks(this,callbackIds)
            for i=1:numel(callbackIds)
                callbackId=callbackIds(i);
                if this.Callbacks.isKey(callbackId)
                    this.Callbacks.remove(callbackId);
                end
            end
        end

        function handleRemoteCallback(this,msg)
            if this.Callbacks.isKey(msg.callbackId)
                callback=this.Callbacks(msg.callbackId);
                args=cellfun(@(a)this.convertInboundValue(a),msg.args,'UniformOutput',false);
                try
                    callback(args{:});
                catch me
                    this.opaqueError(func2str(callback),me.message);
                end
            end
        end

        function runHandleCleanup(this,handleId)
            if~isvalid(this)||this.Client.Disposed
                return;
            end

            cleanupFinished=false;
            replyToken=this.Client.subscribe(this.HANDLE_CLEANUP_INBOUND,@(msg)onHandleCleanupReply(msg));
            subCleanup=onCleanup(@()this.Client.unsubscribe(replyToken));

            this.Client.publish(this.HANDLE_CLEANUP_OUTBOUND,...
            struct('handleId',handleId));
            this.Client.waitFor(@()cleanupFinished,'Interval',0.15);

            function onHandleCleanupReply(msg)
                if msg.handleId==handleId
                    cleanupFinished=true;
                end
            end
        end

        function handleManageRequest(this,msg)
            for i=1:numel(msg.requests)
                if iscell(msg.requests)
                    request=msg.requests{i};
                else
                    request=msg.requests(i);
                end
                try
                    switch request.requestType
                    case 'addNode'
                        this.addNode(request.path,request.name);
                    case 'removeNode'
                        this.removeNode(request.path,request.name);
                    case 'addMethod'
                        this.addMethod(request.path,request.methodSpec);
                    case 'removeMethod'
                        this.removeMethod(request.path,request.methodName);
                    case 'deleteRemoteCallbacks'
                        this.deleteRemoteCallbacks(request.callbackIds);
                    otherwise
                        codergui.internal.WebService.fail(this.Client,this.MANAGE_REPLY,...
                        sprintf('Unrecognized requestType "%s"',request.requestType));
                        return;
                    end
                catch me
                    codergui.internal.WebService.fail(this.Client,this.MANAGE_REPLY,me.getReport());
                    coder.internal.gui.asyncDebugPrint(me);
                    return;
                end
            end
            codergui.internal.WebService.reply(this.Client,this.MANAGE_REPLY,...
            'success',true);
        end

        function handleBusyChange(this,msg)
            this.Busy=msg.busy;
        end

        function handleInvocationReturn(this,msg)
            if this.InvocationResults.isKey(msg.invocationId)
                this.InvocationResults(msg.invocationId)=msg;
            end
        end

        function id=markInvocation(this)
            this.InvocationIdCounter=this.InvocationIdCounter+1;
            id=this.InvocationIdCounter;
            this.InvocationResults(id)=[];
        end

        function child=addNode(this,parentPath,name)
            assert(isvarname(name),'"%s" is not a valid MATLAB variable name',name);
            node=this.getNode(parentPath);
            child=node.x_addChild(name);
        end

        function removeNode(this,parentPath,name)
            node=this.x_getNode(parentPath);
            node.x_removeChild(name);
        end

        function addMethod(this,nodePath,methodSpec)
            assert(isvarname(methodSpec.methodName),'"%s" is not a valid MATLAB variable name',methodSpec.methodName);
            this.getNode(nodePath).x_addMethod(methodSpec);
        end

        function removeMethod(this,nodePath,methodName)
            this.getNode(nodePath).x_removeMethod(methodName);
        end

        function clientWaitFor(this,predicate,varargin)
            this.Client.waitFor(predicate,'ForceSync',true,...
            'Timeout',this.InvocationTimeout,varargin{:});
        end
    end

    methods(Static,Access=private)
        function path=validatePathArg(path)
            if iscell(path)
                assert(isempty(path)||iscellstr(path),'Cell array can only contain characters');
            else
                validateattributes(path,{'char'},{'scalartext'});
                path=strsplit(path,'.');
            end
        end

        function str=printParameterInfo(paramDoc)
            typeStr='';
            if ischar(paramDoc)
                name=paramDoc;
            else
                if isfield(paramDoc,'name')
                    name=paramDoc.name;
                else
                    name='*';
                end
                if isfield(paramDoc,'optional')&&paramDoc.optional
                    name=sprintf('[%s]',name);
                end
                if isfield(paramDoc,'type')&&~isempty(paramDoc.type)
                    if iscell(paramDoc.type)
                        typeStr=strjoin(paramDoc.type,'|');
                    else
                        typeStr=paramDoc.type;
                    end
                    typeStr=sprintf('{%s}',typeStr);
                end
            end
            str=strtrim(sprintf('%s <strong>%s</strong>',typeStr,name));
        end

        function docs=loadApiDocs(docFiles,isDebugMode)
            docs=containers.Map();
            try
                if iscell(docFiles)
                    cellfun(@loadFromFile,docFiles);
                elseif~isempty(docFiles)
                    loadFromFile(docFiles);
                end
            catch me
                if isDebugMode
                    warning('RemoteApi:FailedToLoadDocFile','Failed to load remote API docs: %s',me);
                end
            end

            function loadFromFile(file)
                if~exist(file,'file')
                    if isDebugMode
                        warning('RemoteApi:DocFileMissing','Remote API doc file "%s" could not be found',file);
                    end
                    return;
                end

                fid=fopen(file,'r','n','UTF-8');
                cleanup=onCleanup(@()fclose(fid));
                docContent=jsondecode(fread(fid,[1,inf],'*char'));
                delete(cleanup);

                for i=1:numel(docContent)
                    if iscell(docContent)
                        entry=docContent{i};
                    else
                        entry=docContent(i);
                    end
                    if iscell(entry.method)
                        for j=1:numel(entry.method)
                            docs(entry.method{j})=entry;
                        end
                    else
                        docs(entry.method)=entry;
                    end
                end
            end
        end

        function frames=parseChromeStack(stackText)
            matches=regexp(stackText,...
            'at +([\S]+)? *\(?https?:\/\/(localhost|127\.0\.0\.1):[\d]+\/([\S]+):([\d]+):(?:[\d]+)?\)?','tokens');
            frames=cell2struct(cell(numel(matches),3),{'file','name','line'},2);
            for i=1:numel(frames)
                frames(i).name=matches{i}{1};
                frames(i).file=fullfile(matlabroot,matches{i}{2});
                frames(i).line=str2double(matches{i}{3});
            end
        end

        function opaqueError(methodName,message,stack)
            msgstruct.identifier='coderweb:remoteInvocationFailed';
            msgstruct.message=message;

            msgstruct.stack(1).file='';
            msgstruct.stack(1).name=methodName;
            msgstruct.stack(1).line=0;
            if nargin>2&&~isempty(stack)
                msgstruct.stack=[msgstruct.stack;stack];
            end

            error(msgstruct);
        end
    end
end