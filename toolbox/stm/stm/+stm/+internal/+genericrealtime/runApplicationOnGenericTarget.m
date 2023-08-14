function runApplicationOnGenericTarget(target,applicationName,TestCaseId)





    stopComplete=false;

    try

        try
            endTime=target.getStopTime();
            if(endTime<=0)
                stopComplete=true;
            end
            if endTime==inf
                error(message('stm:realtime:InfiniteTimeLoggingNotSupported'));
            end


            stopSimulation=onCleanup(@()target.stopSimulation());
            target.startSimulation();

            while~stopComplete
                stopComplete=target.allAcquisitionsComplete();
                pause(0.1);
            end
        catch tgException


            ME=MException(message('stm:realtime:LostConnectionToTarget',target.getTargetName()));
            ME=addCause(ME,tgException);
            throw(ME);
        end
    catch ME
        rethrow(ME);
    end

end
