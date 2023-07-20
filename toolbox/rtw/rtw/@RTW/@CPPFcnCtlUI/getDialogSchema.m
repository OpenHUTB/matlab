function dlg=getDialogSchema(hSrc,schemaName)%#ok




    dlg=[];

    txtDescription.Type='text';
    txtDescription.Name=DAStudio.message('RTW:fcnClass:configClassDescription');
    txtDescription.WordWrap=true;
    txtDescription.RowSpan=[1,1];
    txtDescription.ColSpan=[1,10];

    grpDescription.Name=DAStudio.message('RTW:fcnClass:fcnProtoDescription');
    grpDescription.Type='group';
    grpDescription.Items={txtDescription};
    grpDescription.LayoutGrid=[1,10];
    grpDescription.RowSpan=[1,1];
    grpDescription.ColSpan=[1,10];

    listFcnClass=[];
    listFcnClass.Name=DAStudio.message('RTW:fcnClass:memberFunctionClass');
    listFcnClass.Type='combobox';
    listFcnClass.Entries={DAStudio.message('RTW:fcnClass:cppDefault'),...
    DAStudio.message('RTW:fcnClass:cppArgs')};
    theClass=0;
    if~isempty(hSrc.fcnclass)
        switch class(hSrc.fcnclass)
        case 'RTW.ModelCPPArgsClass'
            theClass=1;
        otherwise
            theClass=0;
        end
    end
    listFcnClass.Value=theClass;
    listFcnClass.Source=hSrc;
    listFcnClass.MultiSelect=0;
    listFcnClass.Mode=1;
    listFcnClass.DialogRefresh=1;
    listFcnClass.Tag='listbox';
    listFcnClass.ObjectMethod='FunctionClassChanged';
    listFcnClass.MethodArgs={'%value','%dialog'};
    listFcnClass.ArgDataTypes={'double','handle'};
    listFcnClass.RowSpan=[1,1];
    listFcnClass.ColSpan=[1,2];
    listFcnClass.ToolTip=DAStudio.message('RTW:fcnClass:memberFuncSpecTip');


    tFuncDescription.Type='text';
    tFuncDescription.WordWrap=true;
    tFuncDescription.Name=hSrc.fcnclass.description;
    tFuncDescription.RowSpan=[2,2];
    tFuncDescription.ColSpan=[1,4];


    fcnClass=hSrc.fcnclass;

    bPreConfig.Name=DAStudio.message('RTW:fcnClass:preConfig');
    bPreConfig.Tag='Tag_cpp_fcnproto_preconfig';



    bPreConfig.Visible=fcnClass.needsCompilation();
    bPreConfig.Enabled=bPreConfig.Visible;
    bPreConfig.Type='pushbutton';
    bPreConfig.ToolTip=DAStudio.message('RTW:fcnClass:cppPreConfigTip');
    bPreConfig.MinimumSize=[20,15];
    bPreConfig.Source=hSrc;
    bPreConfig.ObjectMethod='preConfig';
    bPreConfig.MethodArgs={'%dialog'};
    bPreConfig.ArgDataTypes={'handle'};
    bPreConfig.RowSpan=[3,3];
    bPreConfig.ColSpan=[1,1];
    bPreConfig.Mode=true;
    bPreConfig.DialogRefresh=true;
    if isempty(fcnClass.Data)&&~(fcnClass.needsCompilation())



        fcnClass.getDefaultConf();
    end

    txtInvokesUpdateDiagram2.Type='text';
    txtInvokesUpdateDiagram2.Visible=bPreConfig.Visible;
    txtInvokesUpdateDiagram2.Name=DAStudio.message('RTW:fcnClass:invokesUpdateDiagram');
    txtInvokesUpdateDiagram2.WordWrap=false;
    txtInvokesUpdateDiagram2.RowSpan=[3,3];
    txtInvokesUpdateDiagram2.ColSpan=[2,2];

    grpFcnClass.Name=DAStudio.message('RTW:fcnClass:cppSetInterfaceStyle');
    grpFcnClass.Type='group';
    grpFcnClass.Items={listFcnClass,tFuncDescription,bPreConfig,txtInvokesUpdateDiagram2};
    grpFcnClass.LayoutGrid=[3,4];
    grpFcnClass.RowSpan=[2,4];
    grpFcnClass.ColSpan=[1,10];
    grpFcnClass.RowStretch=[0,0,0];

    grpConfig.Name=DAStudio.message('RTW:fcnClass:cppConfigClassInterface');
    grpConfig.Type='group';
    grpConfig.ColStretch=[1,1,1,1,1,1,1,1,1,1];
    grpConfig.RowStretch=[1,1,1,1,1,1,1,1,1];
    grpConfig.LayoutGrid=[9,10];
    grpConfig.RowSpan=[5,11];
    grpConfig.ColSpan=[1,10];
    dialogSchema=hSrc.fcnclass.getSectionDialogSchema('');
    grpConfig.Items=dialogSchema.Items;
    if isempty(grpConfig.Items)
        grpConfig.Visible=false;
    else
        grpConfig.Visible=true;
    end


    bValidate.Name=DAStudio.message('RTW:fcnClass:fcnProtoValidate');
    bValidate.Tag='Tag_cpp_fcnproto_validate';
    bValidate.Type='pushbutton';
    bValidate.ToolTip=DAStudio.message('RTW:fcnClass:validateTip');
    bValidate.MaximumSize=[90,25];
    bValidate.Source=hSrc;
    bValidate.ObjectMethod='validate';
    bValidate.MethodArgs={'%dialog'};
    bValidate.ArgDataTypes={'handle'};
    bValidate.RowSpan=[1,1];
    bValidate.ColSpan=[1,1];
    bValidate.Mode=true;
    bValidate.DialogRefresh=true;

    txtInvokesUpdateDiagram.Type='text';
    txtInvokesUpdateDiagram.Name=DAStudio.message('RTW:fcnClass:invokesUpdateDiagram');
    txtInvokesUpdateDiagram.Visible=fcnClass.needsCompilation();
    txtInvokesUpdateDiagram.WordWrap=false;
    txtInvokesUpdateDiagram.RowSpan=[1,1];
    txtInvokesUpdateDiagram.ColSpan=[2,3];

    validResult.Type='textbrowser';
    validResult.Tag='tValidBrowser';
    validResult.Text='';
    validResult.RowSpan=[2,2];
    validResult.ColSpan=[1,10];

    validResult.Editable=false;

    fontColor='Black';
    bodyBackGroundColorBegin='<body bgcolor="#EEEEEE">';
    bodyBackGroundColorEnd='</body>';
    imgSrc=fullfile(matlabroot,'toolbox','rtw','rtw','@RTW','@FcnCtlUI','icons','icon_info.png');
    if isempty(hSrc.validationResult)
        validResult.Text=DAStudio.message('RTW:fcnClass:validateSucceed');
        imgSrc=fullfile(matlabroot,'toolbox','rtw','rtw','@RTW','@FcnCtlUI','icons','task_passed.png');
    else
        if hSrc.validationStatus
            validResult.Text=hSrc.validationResult;
        else
            validResult.Text=[DAStudio.message('RTW:fcnClass:validationFailed'),...
            '<br/>',...
            DAStudio.message('RTW:fcnClass:fcnProtoError'),' ',...
            hSrc.validationResult];
            fontColor='Red';
            imgSrc=fullfile(matlabroot,'toolbox','rtw','rtw','@RTW','@FcnCtlUI','icons','task_failed.png');
        end
    end

    validResult.Text=[bodyBackGroundColorBegin,'<p>',...
    '<img src="',imgSrc,'"/>','&nbsp;'...
    ,'<font color="',fontColor,'">',...
    validResult.Text,...
    '</font>',...
    '</p>',bodyBackGroundColorEnd];
    grpValid.Name=DAStudio.message('RTW:fcnClass:fcnProtoValidation');
    grpValid.Type='group';
    grpValid.LayoutGrid=[2,10];
    grpValid.RowStretch=[0,1];
    if grpConfig.Visible
        grpValid.RowSpan=[13,14];
    else
        grpValid.RowSpan=[6,7];
    end
    grpValid.ColSpan=[1,10];
    grpValid.RowStretch=[0,1];
    grpValid.Items={bValidate,txtInvokesUpdateDiagram,validResult};

    tDisplay.Type='text';
    tDisplay.Tag='Tag_cpp_fcnproto_preview';
    tDisplay.Name=visualize(hSrc);
    tDisplay.RowSpan=[1,1];
    tDisplay.ColSpan=[1,10];
    tDisplay.WordWrap=true;
    tDisplay.Editable=false;
    tDisplay.Enabled=true;

    grpDisplay.Name=DAStudio.message('RTW:fcnClass:fcnProtoPreview');
    grpDisplay.Type='group';
    grpDisplay.Items={tDisplay};
    grpDisplay.LayoutGrid=[1,10];
    if grpConfig.Visible
        grpDisplay.RowSpan=[12,12];
    else
        grpDisplay.RowSpan=[5,5];
    end
    grpDisplay.ColSpan=[1,10];
    grpDisplay.Visible=true;

    if~hSrc.fcnclass.RightClickBuild
        dlg.DialogTitle=DAStudio.message('RTW:fcnClass:cppDialogTitle',...
        get_param(hSrc.fcnclass.ModelHandle,'Name'));
    else
        dlg.DialogTitle=DAStudio.message('RTW:fcnClass:cppConfigModelInterfaceForSubsys',...
        get_param(hSrc.fcnclass.SubsysBlockHdl,'Name'));
    end
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={'simulink'};
    if grpConfig.Visible
        dlg.LayoutGrid=[14,10];
        dlg.RowStretch=[0,0,0,0,1,1,1,1,1,1,1,0,0,0];
    else
        dlg.LayoutGrid=[7,10];
    end
    dlg.PreApplyCallback='preApplyCB';
    dlg.PreApplyArgs={hSrc,'%dialog'};
    dlg.CloseCallback='closeCB';
    dlg.CloseArgs={hSrc,'%dialog','%closeaction'};
    dlg.DefaultOk=false;
    dlg.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'cp_ecoder_class_interface'};
    dlg.Items={grpDescription,grpFcnClass,grpConfig,grpValid,...
    grpDisplay};


    function signature=visualize(hSrc)

        signature=hSrc.fcnclass.getPreview(hSrc);

