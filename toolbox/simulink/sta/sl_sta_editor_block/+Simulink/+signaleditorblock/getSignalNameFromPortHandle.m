function sigName=getSignalNameFromPortHandle(portH)






    tag=get_param(portH,'Tag');
    splitStr=strsplit(tag,'_');
    sigName=strjoin(splitStr(2:end),'_');

end

