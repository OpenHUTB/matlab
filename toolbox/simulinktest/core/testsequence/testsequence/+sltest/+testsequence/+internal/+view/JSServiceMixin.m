classdef(Abstract)JSServiceMixin<handle
    properties(GetAccess=private,SetAccess=immutable)
        identifier;
        prefix;
        requestChannel;
        responseChannel;
        eventChannel;
        errorChannel;
        queryChannel;
        answerChannel;
        jsMethods=struct();
    end

    properties(Access=protected)
        suspendEvents=false;
    end

    properties(Access=private)
        queryId=0;
        answerReceivers=struct();
        requestSubscription;
        errorSubscription;
        answerSubscription;
        lasterror=[];
        isServicingRequest=false;
        suspendEventsBuffer=struct();
    end

    methods
        function self=JSServiceMixin(channel,prefix)
            self.prefix=prefix;
            self.requestChannel=[channel,'/request'];
            self.responseChannel=[channel,'/response'];
            self.eventChannel=[channel,'/event'];
            self.errorChannel=[channel,'/error'];
            self.queryChannel=[channel,'/query'];
            self.answerChannel=[channel,'/answer'];


            mc=metaclass(self);
            self.identifier=[regexprep(mc.Name,'.*\.',''),':JSService'];
            for m=mc.MethodList'
                if strcmp(m.Name(1:2),prefix)
                    assert(length(m.OutputNames)<=1,'service methods must have either 0 or 1 output');
                    assert(~strcmp(m.Name,[prefix,'Methods']),'%sMethods is a reserved method',prefix);
                    self.jsMethods.(m.Name)=length(m.OutputNames);
                end
            end
        end

        function subscribe(self)

            self.log(@(){'subscribe\n'});
            assert(isempty(self.requestSubscription),'JSService can only be subscribed if unsubscribed');
            connector.ensureServiceOn();

            function handleCallbackErrror(fn,msg)


                try
                    fn(msg);
                catch ME
                    self.errors('add',ME);
                    fwrite(2,ME.getReport());
                end
            end

            self.requestSubscription=message.subscribe(self.requestChannel,@(msg)handleCallbackErrror(@self.dispatchRequest,msg));
            self.errorSubscription=message.subscribe(self.errorChannel,@(msg)handleCallbackErrror(@self.reportError,msg));
            self.answerSubscription=message.subscribe(self.answerChannel,@(msg)handleCallbackErrror(@self.receiveAnswer,msg));
        end

        function unsubscribe(self)

            self.log(@(){'unsubscribe\n'});
            assert(~isempty(self.requestSubscription),'JSService can only be unsubscribed if subscribed');
            if connector.isRunning
                message.unsubscribe(self.requestSubscription);
                message.unsubscribe(self.errorSubscription);
                message.unsubscribe(self.answerSubscription);
            end
            self.requestSubscription=[];
            self.errorSubscription=[];
            self.answerSubscription=[];
        end

        function set.suspendEvents(self,suspend)
            self.suspendEvents=suspend;
            self.flushSuspendedEvents();
        end

        function delete(self)
            assert(isempty(self.requestSubscription),'JSService should be unsubscribed before deletion');
        end
    end

    methods(Access=protected)
        function cleanup=scopedSuspendEvents(self)
            oldSuspendEvents=self.suspendEvents;
            self.suspendEvents=true;
            function resetSuspendEvents(self)
                self.suspendEvents=oldSuspendEvents;
            end
            cleanup=onCleanup(@()resetSuspendEvents(self));
        end

        function emit(self,name,value)
            event.name=name;
            if exist('value','var')
                event.value=value;
            end
            if self.suspendEvents
                if isfield(self.suspendEventsBuffer,name)

                    self.suspendEventsBuffer=rmfield(self.suspendEventsBuffer,name);
                end
                self.suspendEventsBuffer.(name)=event;
                self.log(@(){'suspend %s\n',jsonencode(event)});
            else
                message.publish(self.eventChannel,event);
                self.log(@(){'emit %s\n',jsonencode(event)});
            end
        end

        function log(self,argsfn)
            if self.debug
                args=argsfn();
                fprintf(2,args{:});
            end
        end

        function dispatchRequest(self,request)
            self.log(@(){'%16d >> %s\n',request.id,jsonencode(orderfields(rmfield(request,'id'),{'method','args'}))});
            self.isServicingRequest=true;
            flushEventCleanup=onCleanup(@self.finishRequest);
            if strcmp(request.method,'methods')
                response.id=request.id;
                response.value=fieldnames(self.jsMethods);
                message.publish(self.responseChannel,response);
            elseif strcmp(request.method,'ping')
                response.id=request.id;
                response.value=true;
                message.publish(self.responseChannel,response);
            elseif isfield(self.jsMethods,request.method)
                response.id=request.id;
                try
                    if isnumeric(request.args)||islogical(request.args)||isstruct(request.args)
                        request.args=num2cell(request.args);
                    end
                    if self.jsMethods.(request.method)
                        response.value=self.(request.method)(request.args{:});
                    else
                        self.(request.method)(request.args{:});
                    end
                    message.publish(self.responseChannel,response);
                catch ME

                    self.lasterror=ME;
                    response.error.identifier=ME.identifier;
                    response.error.message=ME.message;
                    response.error.stack=ME.stack;
                    message.publish(self.responseChannel,response);
                    self.log(@(){ME.getReport});
                end
            else
                assert(false,'unknown method %s, args %s',request.method,jsonencode(request.args));
            end
            self.log(@(){'%16d << %s\n',response.id,jsonencode(rmfield(response,'id'))});
        end
    end

    methods(Access=private)
        function flushSuspendedEvents(self)
            if~self.suspendEvents&&~self.isServicingRequest
                for name=fieldnames(self.suspendEventsBuffer)'
                    event=self.suspendEventsBuffer.(name{:});
                    message.publish(self.eventChannel,event);
                    self.log(@(){'flush %s\n',jsonencode(event)});
                end
                self.suspendEventsBuffer=struct();
            end
        end

        function finishRequest(self)
            self.isServicingRequest=false;
            self.flushSuspendedEvents();
        end

        function reportError(self,errmsg)
            self.log(@(){'%16s !! %s\n','',jsonencode(errmsg)});
            self.reportErrorActual(errmsg);
        end

        function reportErrorActual(self,errmsg,morestack)
            if isstruct(errmsg)
                if isfield(errmsg,'name')&&strcmp(errmsg.name,'MATLABError')
                    if~isempty(self.lasterror)...
                        &&strcmp(self.lasterror.identifier,errmsg.identifier)...
                        &&strcmp(self.lasterror.message,errmsg.message)...
                        &&isequal(self.lasterror.stack,errmsg.MATLABStack)

                        self.lasterror.rethrow();
                    else

                        errmsg.stack=errmsg.MATLABStack;
                        if isempty(strfind(errmsg.identifier,':'))

                            errmsg.identifier=[self.identifier,':',errmsg.identifier];
                        end
                    end
                else



                    if~isfield(errmsg,'identifier')
                        if isfield(errmsg,'name')
                            errmsg.identifier=[self.identifier,':',errmsg.name];
                        else
                            errmsg.identifier=self.identifier;
                        end
                    end


                    stack=[];
                    if isfield(errmsg,'stack')



                        stack=arrayfun(@(s)struct('file',strrep(s.file,self.origin,matlabroot),'name',s.name,'line',str2double(s.line)),...
                        regexp(errmsg.stack,'^ +at (\S+ )*(?<name>\S+(?= \())?(?(name) \()(?<file>[^\s\?]+)(?<query>\S+)?:(?<line>\d+):(?<column>\d+)(?(name)\))$|^(?<name>\S+(?=@))?(?(name)@)(?<file>[^\s\?]+)(?<query>\S+)?:(?<line>\d+):(?<column>\d+)$','names','lineanchors'))';
                    end
                    if~isempty(stack)
                        errmsg.stack=stack;
                    elseif all(isfield(errmsg,{'sourceURL','line'}))
                        errmsg.stack=struct('file',strrep(errmsg.sourceURL,self.origin,matlabroot),'name','','line',errmsg.line);
                    else
                        errmsg.stack=struct('file','','name','','line',0);
                    end
                    if exist('morestack','var')
                        errmsg.stack=[errmsg.stack;morestack];
                    end
                end
                error(errmsg);
            elseif ischar(errmsg)
                error(self.identifier,errmsg);
            else
                error(self.identifier,jsonencode(errmsg));
            end
        end
    end

    methods
        function answer=query(self,clientId,method,varargin)
            if strcmp(method,'load')
                assert(ismember(length(varargin),[1,2]),'query(..., ''load'', ...) takes one or two arguments (an absolute path to a file rooted at matlabroot, and a boolean flag to overwrite methods)');
                assert(ismember(varargin{1}(1),'/\'),'first argument of query(..., ''load'', ...) must be an absolute path to a file rooted at matlabroot');
                assert(exist(fullfile(matlabroot,varargin{1}),'file')==2,'query(..., ''load'', ...) of non-existent file %s (rooted at matlabroot)',varargin{1});
            end

            if strcmp(method,'ping')
                queryId='ping';
            else
                queryId=['query',num2str(self.queryId)];
                self.queryId=self.queryId+1;
            end

            msg.waiting=tic();

            function removeReceiver(self,queryId)
                self.answerReceivers=rmfield(self.answerReceivers,queryId);
            end
            cleanupReceiver=onCleanup(@()removeReceiver(self,queryId));

            function receiveAnswer(ansmsg)
                msg=ansmsg;
                if isfield(msg,'progress')
                    msg.progress{1}(end+1)=char(10);
                    self.log(@()msg.progress);
                    msg.waiting=tic();
                else

                    clear cleanupReceiver;
                end
            end
            self.answerReceivers.(queryId)=@receiveAnswer;

            query.clientId=clientId;
            query.queryId=queryId;
            query.method=method;
            query.args=varargin;
            self.log(@(){'%16d <? %s\n',clientId,jsonencode(orderfields(rmfield(query,'clientId'),{'queryId','method','args'}))});
            message.publish(self.queryChannel,query);


            if strcmp(method,'ping')

                pings=1;
                while isfield(msg,'waiting')
                    if toc(msg.waiting)>self.queryTimeout
                        clear cleanupReceiver;
                        msg=rmfield(msg,'waiting');
                        msg.clientId=clientId;
                        msg.answer=false;
                    elseif toc(msg.waiting)>pings
                        message.publish(self.queryChannel,query);
                        pings=pings+1;
                    end
                    drawnow();
                end
                clear pings;
            else

                while isfield(msg,'waiting')
                    if toc(msg.waiting)>self.queryTimeout
                        error([self.identifier,':QueryTimeout'],'%.1fs timeout awaiting answer from clientId %d for query %s',self.queryTimeout,clientId,jsonencode(orderfields(rmfield(query,'clientId'),{'queryId','method','args'})));
                    end
                    drawnow();
                end
            end
            assert(~isfield(msg,'waiting'),'should still be waiting for an answer');


            assert(msg.clientId==clientId,'expected answer from clientId %d but received from clientId %d',clientId,msg.clientId);
            if isfield(msg,'error')
                self.reportErrorActual(msg.error,dbstack('-completenames'));
            elseif isfield(msg,'answer')
                answer=msg.answer;
            else
                assert(strcmp(method,'load'),'only "load" is allowed to return no answers');
            end
        end
    end

    methods(Access=private)
        function receiveAnswer(self,msg)
            self.log(@(){'%16d ?> %s\n',msg.clientId,jsonencode(orderfields(rmfield(msg,'clientId'),intersect({'queryId','progress','answer','error'},fieldnames(msg),'stable')))});
            if isfield(self.answerReceivers,msg.queryId)
                self.answerReceivers.(msg.queryId)(msg);
            elseif~strcmp(msg.queryId,'ping')
                assert(false,'received answer for non-pending requestId %d from clientId %d: %s',msg.queryId,msg.clientId,jsonencode(orderfields(rmfield(msg,{'queryId','clientId'}),intersect({'progress','answer','error'},fieldnames(msg),'stable'))));
            end
        end
    end

    methods(Abstract,Static)
        value=debug(update);
        value=queryTimeout(update);
    end

    properties(Constant)
        queryTimeoutDefault=20;
    end

    methods(Static)
        function url=origin()
            url=connector.getBaseUrl();
            url=url(1:end-1);
        end

        function varargout=errors(cmd,arg,message)

            persistent log

            assert(ismember(cmd,{'add','call','verifyOnCleanup'}),'unknown cmd %s',cmd);

            function report=diag(errors)
                if~exist('message','var')
                    message='Unhandled JSServiceMixin errors detected';
                end

                function result=basename(file)
                    [~,name,ext]=fileparts(file);
                    result=[name,ext];
                end

                function item=diag1(error)
                    file='';
                    if~isempty(error.stack)
                        file=[error.stack(1).name,'@',basename(error.stack(1).file),':',num2str(error.stack(1).line)];
                        if desktop('-inuse')&&~qeinbat()&&~qeInSbRunTests()
                            file=['<a href="error:',error.stack(1).file,',',num2str(error.stack(1).line),'">',file,'</a>'];
                        end
                        file=[' (',file,')'];
                    end
                    item=[error.identifier,file,' - ',strtok(error.message,char(10))];
                end
                [ids,~,idIdx]=unique(cellfun(@diag1,errors,'UniformOutput',false));
                counts=hist(idIdx,unique(idIdx));
                countsIds=[num2cell(counts);ids];
                report=[sprintf('%s\n',message),sprintf('\t(%d) %s\n',countsIds{:})];
            end

            function push()
                if isempty(log)
                    mlock();
                end
                log{end+1}={};
            end

            function value=pop()
                value=log{end};
                log(end)=[];
                if isempty(log)
                    munlock();
                end
            end

            function verify(verifyFail)
                verrors=pop();
                if~isempty(verrors)
                    verifyFail(diag(verrors));
                end
            end

            switch cmd
            case 'add'
                assert(nargin==2,'add takes only one argument');
                if~isempty(log)
                    log{end}{end+1}=arg;
                end

            case 'call'
                assert(nargin<=3,'call takes one or two arguments');
                push();
                try
                    if nargout>0
                        [varargout{1:nargout}]=arg();
                    else
                        arg();
                    end
                catch ME
                    errors=pop();
                    if~isempty(errors)
                        ME.addCause(MException('JSServiceMixin:UnhandledError',diag(errors)));
                    end
                    ME.rethrow();
                end
                errors=pop();
                if~isempty(errors)
                    MException('JSServiceMixin:UnhandledError',diag(errors)).throw();
                end

            case 'verifyOnCleanup'
                assert(nargin<=3,'verifyOnCleanup takes one or two arguments');
                push();
                varargout{1}=onCleanup(@()verify(arg));

            otherwise
                assert(false);
            end
        end
    end
end
