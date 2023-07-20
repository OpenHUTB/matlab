function success=executeCallback(msName,subscriptionId,messageJSON)




    persistent logger
    if isempty(logger)
        logger=connector.internal.Logger('connector::message_service_m');
    end

    msg=mls.internal.fromJSON(messageJSON);

    matchingSubscriptions=message.internal.Subscription.empty;

    if strcmp(msName,'shared')

        strongSubs=message.internal.getSetStrongSubscriptions();
        ind=find([strongSubs.subscriptionId]==subscriptionId);
        matchingSubscriptions(end+1:end+numel(ind))=strongSubs(ind);
        subs=message.internal.getSetWeakSubscriptions();
    else
        try
            ms=message.internal.getSetMessageServiceInstances(msName);
            subs=ms.Subscriptions;
        catch
            subs=matlab.internal.WeakHandle.empty;
        end
    end

    for i=1:numel(subs)
        if~subs(i).isDestroyed()
            sub=subs(i).get();
            if sub.subscriptionId==subscriptionId
                matchingSubscriptions(end+1)=sub;%#ok<AGROW>
            end
        end
    end

    if~isempty(getenv('MW_INSTALL'))
        logger.info(['doExecuteCallback: ',msName,', ',num2str(subscriptionId),', ',num2str(numel(matchingSubscriptions))]);
    end

    if numel(matchingSubscriptions)>0
        for subscription=matchingSubscriptions(:)
            oldState=builtin('_connectorMessageServiceSwitchDebugger',subscription.params.enableDebugger);
            try
                subscription.callback(msg);
            catch ex
                logger.error(['doExecuteCallback error: ',msName,', ',num2str(subscriptionId),', ',getReport(ex,'extended','hyperlinks','off')]);

            end
            builtin('_connectorMessageServiceSwitchDebugger',oldState);
        end
    else
        logger.error(['doExecuteCallback no matching subscriptions: ',num2str(subscriptionId)]);
    end

    success=true;
