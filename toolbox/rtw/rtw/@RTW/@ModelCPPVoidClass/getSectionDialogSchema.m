function dlgstruct=getSectionDialogSchema(hSrc,schemaname)%#ok<INUSD>



    MSLDiagnostic('RTW:fcnClass:voidclassdeprecation').reportAsWarning;
    dlgstruct=[];

    if~hSrc.PreConfigFlag&&isempty(hSrc.FunctionName)
        hSrc.preConfig(hSrc.ViewWidget);
    end


    if isempty(hSrc.cache)
        hSrc.cache=hSrc.copy();
    end

    thisObj=hSrc.cache;

    eFuncName.Type='edit';
    eFuncName.Tag='CPPPrototypeFuncName';
    eFuncName.Name=DAStudio.message('RTW:fcnClass:cppFunctionName');
    eFuncName.MinimumSize=[150,0];
    eFuncName.Mode=true;
    eFuncName.DialogRefresh=true;
    eFuncName.ToolTip=DAStudio.message('RTW:fcnClass:funcNameTip');
    eFuncName.ObjectProperty='FunctionName';
    eFuncName.ValidationCallback=@onNameChanged;
    eFuncName.Source=thisObj;
    eFuncName.RowSpan=[1,1];
    eFuncName.ColSpan=[1,5];

    eClassName.Type='edit';
    eClassName.Tag='CPPPrototypeClassName';
    eClassName.Name=DAStudio.message('RTW:fcnClass:className');
    eClassName.MinimumSize=[150,0];
    eClassName.Mode=true;
    eClassName.DialogRefresh=true;
    eClassName.ToolTip=DAStudio.message('RTW:fcnClass:classNameTip');
    eClassName.ObjectProperty='ModelClassName';
    eClassName.ValidationCallback=@onNameChanged;
    eClassName.Source=thisObj;
    eClassName.RowSpan=[1,1];
    eClassName.ColSpan=[6,10];

    eNamespaceName.Type='edit';
    eNamespaceName.Tag='CPPNamespaceName';
    eNamespaceName.Name=DAStudio.message('RTW:fcnClass:namespaceName');
    eNamespaceName.MinimumSize=[150,0];
    eNamespaceName.Mode=true;
    eNamespaceName.DialogRefresh=true;
    eNamespaceName.ToolTip=DAStudio.message('RTW:fcnClass:namespaceNameTip');
    eNamespaceName.ObjectProperty='ClassNamespace';
    eNamespaceName.ValidationCallback=@onNameChanged;
    eNamespaceName.Source=thisObj;
    eNamespaceName.RowSpan=[1,1];
    eNamespaceName.ColSpan=[11,15];

    dlgstruct.DialogTitle=DAStudio.message('RTW:fcnClass:configModelStep');

    dlgstruct.Items={eFuncName,eClassName,eNamespaceName};


    function onNameChanged(d,r,val,~)
        if~RTW.CPPFcnArgSpec('','Inport','Pointer',val,0,'None',0,0).isValidCPPIdentifier
            source=d.getSource();
            if source.isa('RTW.CPPFcnCtlUI')
                switch r
                case 'CPPPrototypeFuncName'
                    data=source.fcnclass.FunctionName;
                    source.fcnclass.cache.FunctionName=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidFunctionName',val);
                case 'CPPNamespaceName'
                    if isempty(val)
                        return;
                    end
                    data=source.fcnclass.ClassNamespace;
                    source.fcnclass.cache.ClassNamespace=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidNamespaceName',val);
                case 'CPPPrototypeClassName'
                    data=source.fcnclass.ModelClassName;
                    source.fcnclass.cache.ModelClassName=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidClassName',val);
                otherwise
                    data='';
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',val);
                end
            else
                data='';
                msg=DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',val);
            end
            d.setWidgetValue(r,data);
            d.restoreFromSchema;
            error(msg);
        end
