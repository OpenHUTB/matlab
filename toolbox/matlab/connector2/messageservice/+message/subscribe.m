function sub=subscribe(channel,callback,varargin)




    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::message_service_m');
    end

    if connector.isRunning
        p=inputParser;
        p.addParameter('enableDebugger',true,@islogical);
        p.addParameter('name','shared',@ischar);

        p.addParameter('autoUnsub',false,@islogical);
        p.parse(varargin{:});
        params=p.Results;

        if isstring(channel)
            channel=char(channel);
        end



        channel=reshape(channel,1,numel(channel));
        channel=strrep(channel,'//','/');

        if~isa(callback,'function_handle')
            ex=MException(message('MATLAB:connector:connector:InvalidInputParameter',channel));
            ex.throw();
        end

        try
            subscriptionId=builtin('_connectorMessageServiceSubscribe',channel,params.name);
        catch ex
            newEx=MException('Connector:MessageService:InvalidChannel',['Invalid message service channel: ',channel]);
            throw(newEx);
        end

        sub=message.internal.Subscription([],subscriptionId,callback,params);

        if nargout==1&&params.autoUnsub
            subs=message.internal.getSetWeakSubscriptions();
            subs(end+1)=matlab.internal.WeakHandle(sub);
            message.internal.getSetWeakSubscriptions(subs);
        else






            subs=message.internal.getSetStrongSubscriptions();
            subs(end+1)=sub;
            message.internal.getSetStrongSubscriptions(subs);
            sub=subscriptionId;
        end

        logger.info(['subscribed: ',num2str(subscriptionId),', ',channel,' ',params.name]);
    else
        sub=[];
        warning(message('MATLAB:connector:connector:ConnectorNotRunning'));
    end
