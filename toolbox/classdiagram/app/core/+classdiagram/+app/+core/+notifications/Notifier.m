classdef Notifier<handle

    properties(Access=private)
        App;
        waitlist;
        notificationMode;


        channel;
        listener;


        readyToSendListener event.listener;


        actionInfo;
    end

    properties(Access=private,SetObservable)
        isReadyToSend=false;
    end

    properties(Access=private,Hidden)
        keygen=1;
    end

    methods
        function obj=Notifier(app,channelId)
            obj.App=app;
            obj.waitlist=classdiagram.app.core.notifications.Waitlist;
            obj.notificationMode=classdiagram.app.core.notifications.Mode.CL;
            obj.channel=strcat('/Classdiagram/',channelId,'/alertmessagechannel');
            obj.listener=message.subscribe(obj.channel,...
            @(msg)obj.processAlertChannel(msg));
            obj.readyToSendListener=addlistener(...
            obj,'isReadyToSend','PostSet',...
            @(src,evt)ready(obj,src,evt));
        end

        function delete(obj)
            message.unsubscribe(obj.listener);
        end

        function wait(obj,key,val,varargin)

            if isa(val,'string')||isa(val,'char')

                val=obj.makeMessage(val,key,varargin{:});
            end
            obj.waitlist.add(key,val);
        end

        function doneWaiting(obj,optional)
            if~obj.isReadyToSend
                return;
            end
            notifications=obj.waitlist.getAllAndClear();
            obj.notificationMode=classdiagram.app.core.utils.Bitops.unsetFlag(...
            obj.notificationMode,...
            classdiagram.app.core.notifications.Mode.WAIT);

            for ii=1:numel(notifications)
                obj.publishNow(notifications{ii});
            end
        end

        function processNotification(obj,varargin)
            key=string.empty;

            if isa(varargin{1},'message')
                msgObj=varargin{1};
            elseif isa(varargin{1},'MException')
                msgObj=varargin{1};
            else
                messageId=varargin{1};
                if nargin>2
                    key=varargin{2};
                end
                optional={};
                if nargin>3
                    optional=varargin{3:end};
                end
                if isempty(key)
                    msgObj=obj.makeMessage(messageId,optional{:});
                else
                    msgObj=obj.makeMessage(messageId,key,optional{:});
                end
            end

            if isempty(key)
                key=string(obj.keygen);
                obj.keygen=obj.keygen+1;
            end

            if classdiagram.app.core.utils.Bitops.isAnySet(...
                obj.notificationMode,...
                classdiagram.app.core.notifications.Mode.WAIT)
                for notification=msgObj
                    obj.wait(key,notification);
                end
                return;
            end

            for notification=msgObj
                obj.publishNow(notification);
            end
        end

        function publishNow(obj,msg,varargin)
            if isa(msg,'string')||isa(msg,'char')
                msg=obj.makeMessage(msg,varargin{:});
            end
            if classdiagram.app.core.utils.Bitops.isAnySet(obj.notificationMode,...
                classdiagram.app.core.notifications.Mode.UI)
                if~obj.isReadyToSend
                    obj.wait(string(obj.keygen),msg);
                    obj.keygen=obj.keygen+1;
                    return;
                end
                if isa(msg,'MException')
                    msgStr=msg.message;
                else
                    msgStr=msg.string;
                end
                title=message('classdiagram_editor:messages:InfoTitle').string;

                obj.showAlert(title,msgStr);
            end
            if classdiagram.app.core.utils.Bitops.isAnySet(obj.notificationMode,...
                classdiagram.app.core.notifications.Mode.CL)
                obj.issueWarning(msg);
            end
        end

        function clearNotification(obj,key)
            obj.waitlist.remove(key);
        end

        function setMode(obj,varargin)
            obj.notificationMode=...
            classdiagram.app.core.utils.Bitops.setFlag(...
            obj.notificationMode,varargin{:});
        end

        function unsetMode(obj,varargin)
            obj.notificationMode=...
            classdiagram.app.core.utils.Bitops.unsetFlag(...
            obj.notificationMode,varargin{:});
        end

        function resetMode(obj)

            if~obj.isReadyToSend
                obj.readyToSendListener=event.listener.empty;
                obj.readyToSendListener=addlistener(...
                obj,'isReadyToSend','PostSet',...
                @(src,evt)ready(obj,src,evt,'2'));
                return;
            end
            obj.notificationMode=classdiagram.app.core.notifications.Mode.CL;
        end

        function bool=isInUIMode(obj)
            bool=classdiagram.app.core.utils.Bitops.isAnySet(...
            obj.notificationMode,...
            classdiagram.app.core.notifications.Mode.UI);
        end

        function setActionInfo(obj,actionInfo)
            obj.actionInfo=actionInfo;
        end
    end

    methods(Access=private)
        function msg=makeMessage(~,varargin)
            [varargin{:}]=convertStringsToChars(varargin{:});
            msg=message(['classdiagram_editor:messages:'...
            ,varargin{1}],varargin{2:end});
        end

        function processAlertChannel(obj,~)

            obj.isReadyToSend=true;
        end


        function ready(obj,~,~,varargin)
            obj.doneWaiting();
            if~isempty(varargin)
                obj.notificationMode=classdiagram.app.core.notifications.Mode.CL;
            end
            obj.readyToSendListener.Enabled=false;
        end


        function showAlert(obj,title,msg,type)
            if nargin==3
                config=struct('title',title,'message',msg);
            elseif nargin==4
                config=struct('title',title,'message',msg,'type',type);
            end
            if~isempty(obj.actionInfo)
                config.action=obj.actionInfo.action;
                if isfield(obj.actionInfo,"actionArgs")

                    actionFields=fieldnames(obj.actionInfo.actionArgs);
                    for ii=1:numel(actionFields)
                        actionField=actionFields{ii};
                        config.(actionField)=getfield(obj.actionInfo.actionArgs,actionField);
                    end
                end
                obj.actionInfo=struct.empty;
                config.result='Fail';
            end
            message.publish(obj.channel,config);
        end

        function issueWarning(obj,msg)
            if obj.App.isGlobalDebug
                wasTrace=warning('on','backtrace');
                wasVerbose=warning('on','verbose');
            else
                wasTrace=warning('off','backtrace');
                wasVerbose=warning('off','verbose');
            end
            if isa(msg,'MException')
                warning(msg.identifier,msg.message);
            else
                warning(msg);
            end
            warning(wasTrace);
            warning(wasVerbose);
        end

    end
end
