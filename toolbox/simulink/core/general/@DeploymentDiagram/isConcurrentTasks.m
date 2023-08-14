function ret=isConcurrentTasks(modelName)




    modelName=convertStringsToChars(modelName);

    [success,enableCE]=slprivate('safeGetResolvedCSParam',...
    modelName,'ConcurrentTasks');
    ret=success&&...
    strcmpi(enableCE,'on');
end
