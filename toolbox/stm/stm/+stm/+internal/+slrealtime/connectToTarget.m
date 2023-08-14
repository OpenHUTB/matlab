function defaultTargetName=connectToTarget(targetName)

    tgs=slrealtime.Targets;
    defaultTargetName=tgs.getDefaultTargetName;


    targetToUse=targetName;
    if~isempty(targetName)
        if~stm.internal.slrealtime.isTargetDefined(targetName)
            error(message('stm:realtime:TargetUndefined',targetName));
        end
    else

        targetToUse=defaultTargetName;
    end


    if~(strcmpi(targetToUse,defaultTargetName))
        tgs.setDefaultTargetName(targetToUse);
    end



    try
        tg=slrealtime;
        tg.connect;

        if~(tg.isConnected)
            error(message('stm:realtime:UnableToConnectToTarget',targetToUse));
        end
    catch tgException
        ME=MException(message('stm:realtime:UnableToConnectToTarget',targetToUse));
        ME=addCause(ME,tgException);
        throw(ME);
    end
end