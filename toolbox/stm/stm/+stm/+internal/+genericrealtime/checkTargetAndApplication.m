function checkTargetAndApplication(targetName,applicationName)

    tg=slrealtime;

    if~(tg.isConnected)
        error(message('stm:realtime:UnableToConnectToTarget',targetName));
    end









    if(strcmpi(tg.status,'running'))
        error(message('stm:realtime:TargetIsAlreadyRunningAnApplication',applicationName,targetName,tg.get('tc').ModelProperties.Application));
    end

end
