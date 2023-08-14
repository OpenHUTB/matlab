function defaultTargetName=connectToTarget(targetName)

    tgs=slrealtime.Targets;
    defaultTargetName=tgs.getDefaultTargetName;


    targetToUse=targetName;
    if~isempty(targetName)
        if~stm.internal.genericrealtime.isTargetDefined(targetName)
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
        stm.internal.genericrealtime.cleanTargetCoreDumps(tg);
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
