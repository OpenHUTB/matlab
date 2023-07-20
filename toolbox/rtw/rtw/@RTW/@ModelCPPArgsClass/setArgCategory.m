function setArgCategory(hSrc,portName,category)












    if~strcmpi(category,'pointer')&&~strcmpi(category,'value')&&...
        ~strcmpi(category,'reference')
        DAStudio.error('RTW:fcnClass:cppWrongCategory',category);
    end

    if strcmpi(category,'pointer')
        theCategory='Pointer';
    elseif strcmpi(category,'value')
        theCategory='Value';
    else
        theCategory='Reference';
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


