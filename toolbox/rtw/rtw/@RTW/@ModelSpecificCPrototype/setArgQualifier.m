function setArgQualifier(hSrc,portName,qualifier)










    nspQual=regexprep(qualifier,'\s','');

    if~strcmpi(nspQual,'none')&&~strcmpi(nspQual,'const')&&...
        ~strcmpi(nspQual,'const*')&&~strcmpi(nspQual,'const*const')
        DAStudio.error('RTW:fcnClass:wrongQualifier',qualifier);
    end
    theQualifier=lower(nspQual);
    theQualifier=strrep(theQualifier,'*',' * ');
    theQualifier=deblank(theQualifier);

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
    argConf.Qualifier=theQualifier;
    if hSrc.ModelHandle~=0
        hModel=hSrc.ModelHandle;
        set_param(hModel,'RTWFcnClass',hSrc);
    end


