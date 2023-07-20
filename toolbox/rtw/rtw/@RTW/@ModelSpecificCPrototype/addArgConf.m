function addArgConf(hSrc,portName,category,argName,qualifier)


















    if~strcmpi(category,'pointer')&&~strcmpi(category,'value')
        DAStudio.error('RTW:fcnClass:wrongCategory',category);
    end

    nspQual=regexprep(qualifier,'\s','');

    if isempty(nspQual)
        nspQual='none';
    end

    if~strcmpi(nspQual,'none')&&~strcmpi(nspQual,'const')&&...
        ~strcmpi(nspQual,'const*')&&~strcmpi(nspQual,'const*const')
        DAStudio.error('RTW:fcnClass:wrongQualifier',qualifier);
    end

    if strcmpi(category,'pointer')
        theCategory='Pointer';
    else
        theCategory='Value';
    end

    theQualifier=lower(nspQual);
    theQualifier=strrep(theQualifier,'*',' * ');
    theQualifier=deblank(theQualifier);

    configData=hSrc.Data;
    namesInArgSpec=get(configData,'SLObjectName');
    if isempty(namesInArgSpec)
        namesInArgSpec={};
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end
    [num,idx]=ismember(portName,namesInArgSpec);

    argConf=RTW.FcnArgSpec;
    argConf.SLObjectName=portName;
    argConf.Category=theCategory;
    argConf.ArgName=argName;
    argConf.Qualifier=theQualifier;

    if num>0
        argConf.Position=idx;
        hSrc.Data(idx)=argConf;
    else
        currPos=length(configData);
        argConf.Position=currPos+1;
        hSrc.Data=[configData;argConf];
    end
    if hSrc.ModelHandle~=0
        hModel=hSrc.ModelHandle;
        set_param(hModel,'RTWFcnClass',hSrc);
    end
