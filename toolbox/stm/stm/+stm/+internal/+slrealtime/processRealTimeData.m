function processRealTimeData(sdiRunId,targetName,applicationName)

    stm.internal.slrealtime.checkTargetAndApplication(targetName,applicationName);

    try
        tg=slrealtime;
        verifyFileLoc=tg.getVerifyDataFile(applicationName);
        if~isempty(verifyFileLoc)
            stm.internal.slrealtime.addVerifyDataToSDI(verifyFileLoc,sdiRunId);
        end
    catch ME


        if~strcmp(ME.identifier,'slrealtime:target:getVerifyFileError')
            rethrow(ME);
        end
    end


end