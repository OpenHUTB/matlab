function TurnOnFMUDebuggingMode(blockFullPath)


    modelName=blockFullPath(1:(regexp(blockFullPath,'/','once')-1));
    modelHdl=load_system(modelName);

    cs=getActiveConfigSet(modelHdl);
    set_param(cs,'DebugExecutionForFMUViaOutOfProcess','on');

    set_param(blockFullPath,'FMUDebugLogging','on');
    set_param(blockFullPath,'FMUDebugLoggingRedirect','FILE');

    save_system(modelHdl);
end
