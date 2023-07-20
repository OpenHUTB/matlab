function clearBusbarTag




    modelName=get_param(bdroot,'Name');
    DirtyFlag=get_param(modelName,'Dirty');
    set_param(gcb,'Tag','')
    set_param(modelName,'Dirty',DirtyFlag);

end