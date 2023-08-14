function runApplicationOnTarget(targetName,applicationName,TestCaseId)


    stopComplete=false;
    function cb1(~,~)
        stopComplete=true;
    end

    function cb2(~,~)
        ME=MException(message('stm:realtime:ExecutionStoppedBeforeStopTime'));
        throw(ME);
    end

    try
        stm.internal.slrealtime.checkTargetAndApplication(targetName,applicationName);
        tg=slrealtime;

        try

            l1=addlistener(tg,'Stopped',@cb1);
            c1=onCleanup(@()delete(l1));
            l2=addlistener(tg,'StopFailed',@cb2);
            c2=onCleanup(@()delete(l2));
            endTime=tg.get('tc').ModelProperties.StopTime;
            if(endTime<=0)
                stopComplete=true;
            end
            if endTime==inf
                error(message('stm:realtime:InfiniteTimeLoggingNotSupported'));
            end

            time=0;

            tg.start;

            while~stopComplete
                if endTime>0
                    time=tg.ModelStatus.ExecTime;
                    progressValue=time*100/endTime;
                    if~isnan(progressValue)
                        progress=sprintf('%2.0f%%',progressValue);
                        stm.internal.Spinner.updateTestCaseSpinnerLabel(TestCaseId,getString(message('stm:Execution:RunningApplication',progress)));
                    end
                end
                pause(0.1);
            end
        catch tgException


            ME=MException(message('stm:realtime:LostConnectionToTarget',targetName));
            ME=addCause(ME,tgException);
            throw(ME);
        end
        modelStatus=tg.get('ModelStatus');
        if endTime-modelStatus.ExecTime>modelStatus.TETInfo(1).Rate/2
            warning(message('stm:realtime:ExecutionStoppedBeforeStopTime'));
            if contains(tg.TargetStatus.Error,'Overload limit')
                error(message('stm:realtime:CPUOverload'));
            end
        end


        tg.stop;
    catch ME
        rethrow(ME);
    end

end
