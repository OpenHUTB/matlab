function qualifier=getArgQualifier(hSrc,portName)









    configData=hSrc.Data;
    namesInArgSpec=get(configData,'SLObjectName');
    if isempty(namesInArgSpec)
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end
    [num,idx]=ismember(portName,namesInArgSpec);

    if num==0
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    end
    argConf=configData(idx);
    qualifier=argConf.Qualifier;



