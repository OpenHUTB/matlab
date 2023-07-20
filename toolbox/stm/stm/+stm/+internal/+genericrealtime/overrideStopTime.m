function defaultStopTime=overrideStopTime(stopTime)


    try
        tg=slrealtime;
        obj=tg.get('tc');
        defaultStopTime=obj.ModelProperties.StopTime;
        if~isempty(stopTime)&&stopTime~=defaultStopTime
            if(stopTime>0.0)
                tg.setStopTime(stopTime);
                startTime=tic;
                while~(abs(obj.ModelProperties.StopTime-stopTime)<eps)&&...
                    toc(startTime)<obj.Timeout&&...
                    obj.TargetState~=slrealtime.TargetState.TARGET_ERROR
                    pause(.1);
                end
            else





                warning(message('stm:realtime:UnableToSetStopTime',sprintf('%f',stopTime),sprintf('%f',defaultStopTime)));
            end
        end
    catch ME
        rethrow(ME);
    end

end
