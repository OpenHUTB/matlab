function args=extractCreationArgsFromExistingTask(task,propertyNames)




    args=extractPVPairsFromExistingObject(task,propertyNames);
    args=[{task.Function,...
    task.NumOutputArguments,...
    task.InputArguments,},args];
end
