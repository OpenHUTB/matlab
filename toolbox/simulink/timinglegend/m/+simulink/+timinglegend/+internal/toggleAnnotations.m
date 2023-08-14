function toggleAnnotations(modelHandleStr,status)
    modelHandle=str2num(modelHandleStr);
    commandClass=slexec.TimingInfoCommand(modelHandle);
    commandClass.toggleAnnotations(status);
end
