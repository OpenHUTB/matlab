function hardwareManager





    tStart=tic;


    entryPoint="hardwareManager";


    [~,wasShowing]=matlab.hwmgr.internal.launchHardwareManager();


    totalTimeElapsed=toc(tStart);



    if~wasShowing
        try

            dataStruct=struct();

            dataStruct.startupTime=string(totalTimeElapsed*1e3)+"ms";

            dataStruct.entryPoint=entryPoint;

            usageLogger=matlab.hwmgr.internal.UsageLogger();

            usageLogger.logEntryPointAndStartupTime(dataStruct);
        catch

        end
    end

end

