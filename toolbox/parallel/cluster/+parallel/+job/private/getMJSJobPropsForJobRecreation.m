function props=getMJSJobPropsForJobRecreation()




    props=[getCommonJobPropsForJobRecreation(),{'NumWorkersRange',...
    'Timeout',...
    'AuthorizedUsers',...
    'QueuedFcn',...
    'RunningFcn',...
    'FinishedFcn',...
    'RestartWorker'}];
end
