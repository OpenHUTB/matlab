function PreOrPostActionStats=executeAndCollectPrePostActionStats(prePostAction)


    if~isempty(prePostAction)

        try

            PreOrPostActionStats.DesktopStatsBefore=StartDesktopStats;

            startTime=tic;


            evalin('base',prePostAction);
            elapsedTime=toc(startTime);


            PreOrPostActionStats.correctness=true;
            PreOrPostActionStats.errormsg='';
            PreOrPostActionStats.errormsgId='';
        catch err
            elapsedTime=toc(startTime);
            PreOrPostActionStats.correctness=false;
            [PreOrPostActionStats.errormsg,PreOrPostActionStats.errormsgId]=lasterr;
            PreOrPostActionStats.DesktopStatsAfter=EndDesktopStats;
            PreOrPostActionStats.DesktopStatsAfter.elapsedTime=elapsedTime;
            rethrow(err);
        end
        PreOrPostActionStats.DesktopStatsAfter=EndDesktopStats;
        PreOrPostActionStats.DesktopStatsAfter.elapsedTime=elapsedTime;

    else
        PreOrPostActionStats=[];
    end

end