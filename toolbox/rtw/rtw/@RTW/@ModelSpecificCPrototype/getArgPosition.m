function pos=getArgPosition(hSrc,portName)











    configData=hSrc.Data;
    namesInArgSpec=get(configData,'SLObjectName');
    if isempty(namesInArgSpec)
        pos=0;
        return;
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end
    [num,idx]=ismember(portName,namesInArgSpec);

    if num>0
        pos=configData(idx).Position;
    else
        pos=0;
    end

