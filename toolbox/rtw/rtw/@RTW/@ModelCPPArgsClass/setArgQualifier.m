function setArgQualifier(hSrc,portName,qualifier)










    nspQual=regexprep(qualifier,'\s','');

    if~strcmpi(nspQual,'none')&&~strcmpi(nspQual,'const')&&...
        ~strcmpi(nspQual,'const*')&&~strcmpi(nspQual,'const*const')&&...
        ~strcmpi(nspQual,'const&')
        DAStudio.error('RTW:fcnClass:cppWrongQualifier',qualifier);
    end
    theQualifier=lower(nspQual);
    theQualifier=strrep(theQualifier,'*',' * ');
    theQualifier=strrep(theQualifier,'&',' & ');
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


