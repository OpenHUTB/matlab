classdef(Sealed)MessagingHelper<handle
    properties(Hidden,Dependent,SetAccess=immutable)
Mappings
    end

    properties(SetAccess=immutable)
        ChannelPrefix=''
WebClient
BoundObject
ResponseFormatter
ErrorFormatter
IdField
    end

    properties(Dependent,SetAccess=immutable)
AbsoluteChannelRoot
    end

    properties(Access=private)
        Handlers=struct('handler',{},'replyMode',{},'in',{},'out',{},'rawIn',{},'rawOut',{},'subscriptions',{})
ObjectListener
        Attached=false
    end

    methods
        function this=MessagingHelper(varargin)
            ip=inputParser();
            ip.addParameter('ChannelPrefix','',@(v)iscellstr(v)||ischar(v));%#ok<ISCLSTR>
            ip.addParameter('WebClient',[],@(v)isa(v,'codergui.WebClient')||isempty(v));
            ip.addParameter('BindTo',[],@(v)isobject(v));
            ip.addParameter('ResponseFormatter',[],@(v)isempty(v)||isa(v,'function_handle'));
            ip.addParameter('ErrorFormatter',[],@(v)isempty(v)||isa(v,'function_handle'));
            ip.addParameter('IdField','requestId',@ischar);
            ip.addParameter('Mappings',cell(0,3),@iscell);
            ip.parse(varargin{:});
            opts=ip.Results;

            if~isempty(opts.WebClient)
                this.WebClient=opts.WebClient;
            end
            if~isempty(opts.ChannelPrefix)
                if iscell(opts.ChannelPrefix)
                    this.ChannelPrefix=joinChannelTokens(opts.ChannelPrefix{:});
                else
                    this.ChannelPrefix=joinChannelTokens(opts.ChannelPrefix);
                end
            end

            if~isempty(opts.ResponseFormatter)
                this.ResponseFormatter=opts.ResponseFormatter;
            end
            if~isempty(opts.ErrorFormatter)
                this.ErrorFormatter=opts.ErrorFormatter;
            end
            this.IdField=opts.IdField;

            this.BoundObject=opts.BindTo;
            if~isempty(this.BoundObject)&&isa(this.BoundObject,'handle')
                this.ObjectListener=this.BoundObject.listener('ObjectBeingDestroyed',@(~,~)this.deactivate());
            end

            if~isempty(opts.Mappings)
                this.multiMap(opts.Mappings);
            end
        end

        function multiMap(this,mappings)
            validateattributes(mappings,{'cell'},{'ndims',2,'ncols',4})
            for i=1:size(mappings,1)
                this.map(mappings{i,:});
            end
        end

        function mapVoid(this,inChannel,handler)
            this.map('void',inChannel,'',handler);
        end

        function mapOutput(inChannel,outChannel,handler)
            if nargin<3
                handler=outChannel;
                outChannel='';
            end
            this.map('output',inChannel,outChannel,handler);
        end

        function mapGeneric(inChannel,outChannel,handler)
            if nargin<3
                handler=outChannel;
                outChannel='';
            end
            this.map('generic',inChannel,outChannel,handler);
        end

        function map(this,replyMode,inChannel,outChannel,handler)
            narginchk(4,5);
            if nargin<5
                handler=outChannel;
                outChannel='';
            end
            if isempty(replyMode)
                replyMode='void';
            end
            replyMode=validatestring(replyMode,{'void','output','async','generic'});
            this.registerHandler(replyMode,handler,inChannel,outChannel);
        end

        function attach(this)
            if this.Attached
                return
            end
            this.Attached=true;
            this.subscribeNow();
        end

        function detach(this)
            if~this.Attached
                return
            end
            this.unsubscribeAll();
        end

        function delete(this)
            this.deactivate();
        end

        function prefixPublish(this,channel,data)
            this.publish(strjoin({this.ChannelPrefix,regexprep(channel,'^\/|\/$','')},'/'),data);
        end

        function publish(this,channel,data)
            if~isempty(this.WebClient)
                this.WebClient.publish(channel,data);
            else
                message.publish(channel,data);
            end
        end

        function mappings=get.Mappings(this)
            mappings=[{this.Handlers.rawIn};{this.Handlers.rawOut};{this.Handlers.handler};{this.Handlers.replyMode}]';
        end

        function root=get.AbsoluteChannelRoot(this)
            if isempty(this.WebClient)
                root='';
            else
                root=this.WebClient.channel(this.ChannelPrefix);
            end
        end
    end

    methods(Access=private)
        function registerHandler(this,replyMode,handler,inChannel,outChannel)
            if ischar(handler)
                handlerName=handler;
                if~isempty(this.BoundObject)
                    handler=@(varargin)feval(handlerName,this.BoundObject,varargin{:});
                else
                    handler=str2func(handlerName);
                end
            elseif~isa(handler,'function_handle')
                error('Handlers must function handles, method names, or function names');
            end
            normIn=this.normalizeChannel(inChannel);
            if replyMode~="void"&&isempty(outChannel)
                normOut=outChannel;
            else
                normOut=this.normalizeChannel(outChannel);
            end

            handlerIndex=numel(this.Handlers)+1;
            this.Handlers(handlerIndex).handler=handler;
            this.Handlers(handlerIndex).rawIn=inChannel;
            this.Handlers(handlerIndex).rawOut=outChannel;
            this.Handlers(handlerIndex).in=normIn;
            this.Handlers(handlerIndex).out=normOut;
            this.Handlers(handlerIndex).replyMode=replyMode;
            this.Handlers(handlerIndex).subscriptions=0;
            this.subscribeNow(handlerIndex);
        end

        function subscribeNow(this,handlerIndices)
            if~this.Attached
                return
            end
            if nargin<2
                handlerIndices=1:numel(this.Handlers);
            end
            if isempty(handlerIndices)
                return
            end

            webClient=this.WebClient;
            subTokens=num2cell(zeros(1,numel(handlerIndices)));

            for i=1:numel(handlerIndices)
                context=this.Handlers(handlerIndices(i));
                proxy=@(msg)this.dispatch(context,msg);
                if~isempty(webClient)
                    subTokens{i}=webClient.subscribe(context.in,proxy);
                else
                    subTokens{i}=message.subscribe(context.in,proxy);
                end
            end

            [this.Handlers(handlerIndices).subscriptions]=subTokens{:};
        end

        function dispatch(this,handlerContext,msg)
            shouldRespond=true;
            hasOutput=false;
            switch handlerContext.replyMode
            case 'output'
                hasOutput=true;
            case 'void'
                shouldRespond=false;
            case 'generic'
            otherwise
                error('Unrecongized replyMode value: %s',handlerContext.replyMode);
            end

            if isstruct(msg)&&isfield(msg,this.IdField)
                requestId=msg.(this.IdField);
            else
                requestId=[];
            end

            handler=handlerContext.handler;
            try
                if~shouldRespond||~hasOutput
                    handler(msg);
                    if shouldRespond
                        responseData=codergui.internal.undefined();
                    else
                        return
                    end
                else
                    responseData=handler(msg);
                end
            catch me
                if shouldRespond
                    doRespondError(me);
                end
                return
            end

            codergui.internal.util.when(responseData,'then',@doRespond,@doRespondError);

            function doRespond(responseData)
                if~isempty(this.ResponseFormatter)
                    responseData=feval(this.ResponseFormatter,handlerContext.rawIn,responseData);
                else
                    responseData=defaultMessageFormat(responseData,requestId);
                end
                this.publish(handlerContext.out,responseData);
            end

            function doRespondError(me)
                if~isempty(this.ErrorFormatter)
                    errMessage=feval(this.ErrorFormatter,handlerContext.in,me,requestId);
                else
                    errMessage=defaultErrorFormat(me,requestId);
                end
                this.publish(handlerContext.out,errMessage);
            end
        end

        function unsubscribeAll(this)
            allSubs=[this.Handlers.subscriptions];
            allSubs=allSubs(allSubs~=0);
            if isempty(allSubs)
                return;
            end

            empties=cell(1,numel(this.Handlers));
            [this.Handlers.subscriptions]=empties{:};

            if~isempty(this.WebClient)
                for sub=allSubs
                    this.WebClient.unsubscribe(sub);
                end
            else
                for sub=allSubs
                    message.unsubscribe(sub);
                end
            end
        end

        function deactivate(this)
            this.unsubscribeAll();
            this.ObjectListener=[];
        end

        function channel=normalizeChannel(this,channel)
            if isempty(channel)
                error('Channel arguments must be non-empty char vectors');
            end
            channel=joinChannelTokens(this.ChannelPrefix,channel);
            if isempty(this.WebClient)
                channel=['/',channel];
            end
        end
    end
end


function payload=defaultMessageFormat(raw,requestId)
    if~isempty(requestId)
        payload.requestId=requestId;
    end
    payload.success=true;
    if~codergui.internal.undefined(raw)
        payload.data=raw;
    end
end


function payload=defaultErrorFormat(rawErr,requestId)
    if~isempty(requestId)
        payload.requestId=requestId;
    end
    payload.success=false;
    if~ischar(rawErr)&&~isstring(rawErr)
        payload.error=struct('identifier',rawErr.identifier,'message',rawErr.message,...
        'internal',codergui.internal.util.isInternalError(rawErr));
    else
        payload.error=rawErr;
    end
end


function channel=joinChannelTokens(varargin)
    channel=regexprep(strjoin(varargin,'/'),'/{2,}','/');
    if endsWith(channel,'/')
        channel=channel(1:end-1);
    end
end
