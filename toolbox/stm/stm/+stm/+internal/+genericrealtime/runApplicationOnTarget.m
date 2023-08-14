function runApplicationOnTarget(targetName,applicationName,TestCaseId)

    try
        stopComplete=false;
        stm.internal.slrealtime.checkTargetAndApplication(targetName,applicationName);
        tg=slrealtime;

        try
            endTime=tg.get('tc').ModelProperties.StopTime;
            if(endTime<=0)
                stopComplete=true;
            end
            if isinf(endTime)
                error(message('stm:realtime:InfiniteTimeLoggingNotSupported'));
            end

            tg.start;

            while~stopComplete
                time=tg.ModelStatus.ExecTime;
                progressValue=time*100/endTime;
                if~isnan(progressValue)
                    progress=sprintf('%2.0f%%',progressValue);
                    stm.internal.Spinner.updateTestCaseSpinnerLabel(TestCaseId,getString(message('stm:Execution:RunningApplication',progress)));
                end
                pause(0.1);
                stopComplete=~tg.isRunning;
            end
        catch tgException

            ME=MException(message('stm:realtime:LostConnectionToTarget',targetName));
            ME=addCause(ME,tgException);
            throw(ME);
        end

        tg.stop;

        modelStatus=tg.ModelStatus;
        if endTime-modelStatus.ExecTime>modelStatus.TETInfo(1).Rate/2
            warning(message('stm:realtime:ExecutionStoppedBeforeStopTime'));
        end

        if contains(modelStatus.Error,'Overload limit')
            error(message('stm:realtime:CPUOverload'));
        end

        if(modelStatus.State==slrealtime.ModelState.MODEL_ERROR)
            error(message('stm:realtime:ErrorDuringRealTimeExecution',modelStatus.Error));
        end
    catch ME
        rethrow(ME);
    end
end