function resetLogs(tg)












    commands=...
"slrealtime stopdaemon; slrealtime stoplogd; "...
    +"rm -f /home/slrt/logs/*; "...
    +"slrealtime startdaemon; slrealtime startlogd; ";
    tg.executeCommand(commands,tg.getRootSSHObj());
end
