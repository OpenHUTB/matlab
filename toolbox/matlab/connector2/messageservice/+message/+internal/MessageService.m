classdef(Hidden=true)MessageService<handle


    properties
Name
Options
Subscriptions
Logger
    end

    methods(Static)
        function subscriptions=getSubscriptions
            subscriptions=message.internal.getSetStrongSubscriptions;
            subscriptions=cat(1,subscriptions,message.internal.getSetWeakSubscriptions);
        end

        function executeCallback(sub,messageJSON)
            if isa(sub,'uint64')
                subscriptionId=sub;
            else
                subscriptionId=sub.subscriptionId;
            end
            message.internal.executeCallback('shared',subscriptionId,messageJSON)
        end
    end

    methods
        function obj=MessageService(name,varargin)
mlock
            obj.Name=char(name);
            if nargin>1
                obj.Options=varargin{1};
            else
                obj.Options=struct();
            end
            obj.Subscriptions=matlab.internal.WeakHandle.empty;

            obj.Logger=connector.internal.Logger('connector::message_service_m');

            if~isvarname(obj.Name)
                error('Name must follow variable naming rules.');
            end

            if~connector.isRunning
                error(message('MATLAB:connector:connector:ConnectorNotRunning'));
            end

            builtin('_connectorMessageServiceCreate',obj.Name,obj.Options);

            message.internal.getSetMessageServiceInstances(obj);
        end

        function delete(obj)
            obj.Logger.info(['Deleting MessageService instance ',obj.Name]);
            for i=numel(obj.Subscriptions):-1:1
                sub=obj.Subscriptions(i);
                if~sub.isDestroyed()
                    obj.unsubscribe(sub.get());
                end
            end
            builtin('_connectorMessageServiceRelease',obj.Name);
        end

        function sub=subscribe(obj,channel,callback,varargin)
            p=inputParser;
            p.addParameter('enableDebugger',true,@islogical);
            p.parse(varargin{:});

            if~isa(callback,'function_handle')
                ex=MException(message('MATLAB:connector:connector:InvalidInputParameter',channel));
                ex.throw();
            end

            channel=char(channel);

            id=builtin('_connectorMessageServiceSubscribe',channel,obj.Name);

            sub=message.internal.Subscription(obj,id,callback,p.Results);
            obj.Subscriptions(end+1)=matlab.internal.WeakHandle(sub);

            obj.Logger.info(['subscribed: ',num2str(id),', ',channel,' ',obj.Name]);
        end

        function unsubscribe(obj,sub)
            if~isnumeric(sub.subscriptionId)&&numel(sub.subscriptionId)==1
                error('unsubscribe invalid argument');
            end

            obj.Logger.info(['unsubscribe: ',num2str(sub.subscriptionId),' ',obj.Name]);

            keepSubs=true(size(obj.Subscriptions));
            for i=1:numel(obj.Subscriptions)
                if obj.Subscriptions(i).isDestroyed()||obj.Subscriptions(i).get().subscriptionId==sub.subscriptionId
                    keepSubs(i)=false;
                end
            end
            obj.Subscriptions=obj.Subscriptions(keepSubs);
            builtin('_connectorMessageServiceUnsubscribe',sub.subscriptionId,obj.Name);
        end

        function publish(obj,channel,msg)
            messageJSON=unicode2native(mls.internal.toJSON(msg),'UTF-8');
            builtin('_connectorMessageServicePublish',channel,messageJSON,obj.Name);
        end
    end
end
