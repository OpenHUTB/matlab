function status = sldvAsyncLaunchTask(args,resFile,goals, sldvAnalyzer)
%

%   Copyright 2020-2021 The MathWorks, Inc.

    status          = false;
    args = [args resFile];
    cmdString = strjoin(args) ;
    if ~isempty(goals)
        task = dv.tasking.CmdWithObjectivesTask(0, cmdString, goals);
    else
        % The "MultiProcessEnv" flag is used to prototype multiple process
        % environment with 2 dvoserver processes. 
        % When flag = 1, Single dvoserver process that runs Concolic + PS
        % When flag = 2, 2 dvoserver processes which run Concolic and PS in
        % different processes
        if (slavteng('feature', 'MultiProcessEnv') > 1)
            args1 = args;
            args{3} = 'concolic'; % concolic
            cmdString = strjoin(args) ;
            args1{3} = 'psForTCG'; % Polyspace
            cmdString1 = strjoin(args1) ;
            task1 = dv.tasking.SingleCommandTask(0, cmdString1);
        elseif (slavteng('feature', 'MultiProcessEnv') > 0)
            args{3} = 'concolic_ps'; % concolic
            cmdString = strjoin(args) ;

        end
        task = dv.tasking.SingleCommandTask(0, cmdString);
    end
    taskQueue = sldvAnalyzer.getTaskQueue();

    if taskQueue.isConnected()
        if (slavteng('feature', 'MultiProcessEnv') > 1)
            taskQueue.push(task1, 0);
        end
        taskQueue.push(task, 0);
        status = true;
    else
        status = false;
    end
end
