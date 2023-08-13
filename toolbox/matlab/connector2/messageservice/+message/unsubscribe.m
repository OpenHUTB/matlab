function unsubscribe(sub,varargin)

    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::message_service_m');
    end

    if connector.isRunning


        if numel(sub)==1&&((metaclass(sub)==?message.internal.Subscription)||isa(sub,'uint64'))
            if isa(sub,'uint64')
                subscriptionId=sub;
            else
                subscriptionId=sub.subscriptionId;
            end

            logger.info(['unsubscribe: ',num2str(subscriptionId),' shared']);

            builtin('_connectorMessageServiceUnsubscribe',subscriptionId,'shared');


            subs=message.internal.getSetWeakSubscriptions;
            keepSubs=true(size(subs));
            for i=1:numel(subs)
                if subs(i).isDestroyed()||subs(i).get().subscriptionId==subscriptionId
                    keepSubs(i)=false;
                end
            end
            subs=subs(keepSubs);
            message.internal.getSetWeakSubscriptions(subs);


            subs=message.internal.getSetStrongSubscriptions;
            keepSubs=true(size(subs));
            for i=1:numel(subs)
                if subs(i).subscriptionId==subscriptionId
                    keepSubs(i)=false;
                end
            end
            subs=subs(keepSubs);
            message.internal.getSetStrongSubscriptions(subs);
        else
            try
                logger.warning(['doUnsubscribe invalid argument: ',mls.internal.toJSON(sub)]);
            catch ex
                logger.warning('doUnsubscribe invalid argument');
            end
        end
    else
        warning(message('MATLAB:connector:connector:ConnectorNotRunning'));
    end
