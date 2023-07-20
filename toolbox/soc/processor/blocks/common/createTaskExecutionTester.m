function hObj=createTaskExecutionTester(modelName)




    if(1==nargin)
        if~isequal(exist(modelName,'file'),4)
            error(message('soc:utils:ModelDoesNotExist',modelName));
        end
        hObj=soc.internal.TaskExecutionTester(modelName);
    else
        hObj=soc.internal.TaskExecutionTester();
    end

end
