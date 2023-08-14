function toggleDisplayForRate(modelHandleStr,annotation,status)
    modelHandle=str2num(modelHandleStr);
    commandClass=slexec.TimingInfoCommand(modelHandle);
    commandClass.toggleDisplayForRate(annotation,status);
end
