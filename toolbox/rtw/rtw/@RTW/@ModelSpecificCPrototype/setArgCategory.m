function setArgCategory(hSrc,portName,category)












    if~strcmpi(category,'pointer')&&~strcmpi(category,'value')
        DAStudio.error('RTW:fcnClass:wrongCategory',category);
    end

    if strcmpi(category,'pointer')
        theCategory='Pointer';
    else
        theCategory='Value';
    end

    configData=hSrc.Data;
    namesInArgSpec=get(configData,'SLObjectName');
    if isempty(namesInArgSpec)
        namesInArgSpec={};
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end
    [num,idx]=ismember(portName,namesInArgSpec);

    if num==0
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    end
    argConf=configData(idx);
    argConf.Category=category;
    if hSrc.ModelHandle~=0
        hModel=hSrc.ModelHandle;
        set_param(hModel,'RTWFcnClass',hSrc);
    end

