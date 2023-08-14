function name=getUnusedTaskName(mdlHdl)
    tcg=sltp.TaskConnectivityGraph(get_param(mdlHdl,'name'));
    name=tcg.getUnusedTaskName;
end