function grpValid=getValidateGrpSchema(hSrc,hParent)%#ok<INUSL>



    bValidate.Name=DAStudio.message('RTW:fcnClass:fcnProtoValidate');
    bValidate.Tag='Tag_fcnproto_validate';
    bValidate.Type='pushbutton';
    bValidate.ToolTip=DAStudio.message('RTW:fcnClass:validateTip');
    bValidate.MaximumSize=[90,25];
    bValidate.ObjectMethod='validate';
    bValidate.MethodArgs={'%dialog'};
    bValidate.ArgDataTypes={'handle'};
    bValidate.RowSpan=[1,1];
    bValidate.ColSpan=[1,1];
    bValidate.Mode=true;
    bValidate.DialogRefresh=true;

    txtInvokesUpdateDiagram.Type='text';
    txtInvokesUpdateDiagram.Name=DAStudio.message('RTW:fcnClass:invokesUpdateDiagram');
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
    if isempty(hParent.validationResult)
        validResult.Text=DAStudio.message('RTW:fcnClass:validateSucceed');
        imgSrc=fullfile(matlabroot,'toolbox','rtw','rtw','@RTW','@FcnCtlUI','icons','task_passed.png');
    else
        if hParent.validationStatus
            validResult.Text=hParent.validationResult;
        else
            validResult.Text=[DAStudio.message('RTW:fcnClass:validationFailed'),...
            '<br/>',...
            DAStudio.message('RTW:fcnClass:fcnProtoError'),...
            hParent.validationResult];
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
    grpValid.Items={bValidate,txtInvokesUpdateDiagram,validResult};
