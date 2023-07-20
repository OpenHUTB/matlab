



function dlg=getDialogSchema(hObj,unused)%#ok<INUSD>

    descLbl.Type='text';
    descLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIdescLbl');
    descLbl.RowSpan=[1,1];
    descLbl.ColSpan=[1,1];
    descLbl.WordWrap=true;

    descPanel.Type='group';
    descPanel.Name=pslinkprivate('pslinkMessage','get','pslink:GUIdescPanel');
    descPanel.LayoutGrid=[1,1];
    descPanel.Items={descLbl};

    kindLbl.Type='text';
    kindLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIkindLbl');
    kindLbl.RowSpan=[1,1];
    kindLbl.ColSpan=[1,1];

    kindList.Type='combobox';
    kindList.ObjectProperty='PSAnnotationType';
    kindList.Source=hObj;
    kindList.Mode=true;
    kindList.DialogRefresh=true;
    kindList.RowSpan=[1,1];
    kindList.ColSpan=[2,3];
    kindList.Tag=['_pslink_',kindList.ObjectProperty,'_tag'];

    modeChk.Type='checkbox';
    modeChk.Source=hObj;
    modeChk.ObjectProperty='PSOnlyOneCheck';
    modeChk.Mode=true;
    modeChk.DialogRefresh=true;
    modeChk.RowSpan=[2,2];
    modeChk.ColSpan=[1,3];
    modeChk.Tag=['_pslink_',modeChk.ObjectProperty,'_tag'];

    checkLbl.Type='text';
    checkLbl.Name='';
    checkLbl.RowSpan=[3,3];
    checkLbl.ColSpan=[1,1];

    checkCombo.Type='combobox';
    checkCombo.RowSpan=[3,3];
    checkCombo.ColSpan=[2,3];
    checkCombo.Tag='_pslink_PSAnnotationKind_combo_tag';
    checkCombo.Visible=false;

    checkEdit.Type='edit';
    checkEdit.RowSpan=[3,3];
    checkEdit.ColSpan=[2,3];
    checkEdit.Tag='_pslink_PSAnnotationKind_edit_tag';
    checkEdit.Visible=false;
    checkEdit.Value=hObj.PSAnnotationKind;

    if strcmpi(hObj.PSAnnotationType,'Check')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkCheck');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCheck');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','checks');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','rte',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCheckList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditCheckList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'rte',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'defect')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkDefect');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblDefect');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','defect');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','defect',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblDefectList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditDefectList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'defect',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'misra-ac-agc')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisraAgc');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','misraagc');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','misra-ac-agc',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisraAgcList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditMisraAgcList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'misra-ac-agc',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'misra-c')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisra');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','misra');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','misra-c',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisraList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditMisraList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'misra-c',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'misra-c-2012')
        modeChk.Name=DAStudio.message('polyspace:gui:pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=DAStudio.message('polyspace:gui:pslink:GUIcheckLblMisraC2012');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','misrac2012');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','misra-c3',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=DAStudio.message('polyspace:gui:pslink:GUIcheckLblMisraC2012List');
            checkEdit.ToolTip=DAStudio.message('polyspace:gui:pslink:GUIcheckEditMisraC2012List');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'misra-c3',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'misra-c++')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisraCxx');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','misracxx');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','misra-cpp',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblMisraCxxList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditMisraCxxList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'misra-cpp',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'jsf')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblJsf');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','jsf');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','jsf',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblJsfList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditJsfList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'jsf',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'ISO-17961')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblIso');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','iso-17961');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','iso-17961',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblIsoList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditIsoList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'iso-17961',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'CERT-C')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCertC');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','certc');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','cert-c',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCertCList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditCertCList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'cert-c',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'CERT-CPP')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCertCpp');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','certcpp');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','cert-cpp',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCertCppList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditCertCppList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'cert-cpp',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'AUTOSAR-CPP14')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblAutosar');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','autosar');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','autosar-cpp14',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblAutosarList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditAutosarList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'autosar-cpp14',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'GUIDELINES')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblGuideline');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','guidelines');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','guideline',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblGuidelineList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditGuidelineList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'guideline',checkEdit.Value);
        end
    elseif strcmpi(hObj.PSAnnotationType,'CUSTOM')
        modeChk.Name=pslinkprivate('pslinkMessage','get','pslink:GUImodeChkMisra');
        if hObj.PSOnlyOneCheck
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCustom');
            checkCombo.Entries=pslinkprivate('getAnnotationValues','custom');
            checkCombo.Visible=true;
            checkIdx=pslinkprivate('annotationHelper','firstMatchIdx','custom',hObj.PSAnnotationKind);
            if~isempty(checkIdx)
                checkCombo.Value=checkIdx;
            else
                checkEdit.Value='';
            end
        else
            checkLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcheckLblCustomList');
            checkEdit.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcheckEditCustomList');
            checkEdit.Visible=true;
            checkEdit.Value=pslinkprivate('annotationHelper','reformatChecklist',...
            'custom',checkEdit.Value);
        end
    end

    statusLbl.Type='text';
    statusLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIstatusLbl');
    statusLbl.RowSpan=[4,4];
    statusLbl.ColSpan=[1,1];

    statusList.Type='combobox';
    statusList.ObjectProperty='PSStatus';
    statusList.Source=hObj;
    statusList.Mode=true;
    statusList.RowSpan=[4,4];
    statusList.ColSpan=[2,3];
    statusList.Tag=['_pslink_',statusList.ObjectProperty,'_tag'];

    classLbl.Type='text';
    classLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIclassLbl');
    classLbl.RowSpan=[5,5];
    classLbl.ColSpan=[1,1];

    classList.Type='combobox';
    classList.ObjectProperty='PSClassification';
    classList.Source=hObj;
    classList.Mode=true;
    classList.RowSpan=[5,5];
    classList.ColSpan=[2,3];
    classList.Tag=['_pslink_',classList.ObjectProperty,'_tag'];

    commentLbl.Type='text';
    commentLbl.Name=pslinkprivate('pslinkMessage','get','pslink:GUIcommentLbl');
    commentLbl.RowSpan=[6,6];
    commentLbl.ColSpan=[1,1];

    commentTxt.Type='edit';
    commentTxt.ObjectProperty='PSComment';
    commentTxt.ToolTip=pslinkprivate('pslinkMessage','get','pslink:GUIcommentTxtTooltip');
    commentTxt.Source=hObj;
    commentTxt.Mode=true;
    commentTxt.RowSpan=[6,8];
    commentTxt.ColSpan=[2,3];
    commentTxt.Tag=['_pslink_',commentTxt.ObjectProperty,'_tag'];

    panel.Type='group';
    panel.Name=pslinkprivate('pslinkMessage','get','pslink:GUIpanelAnnot');
    panel.LayoutGrid=[9,3];
    panel.ColStretch=[0,0,1];
    panel.RowStretch=[0,0,0,0,0,0,0,0,1];
    panel.RowSpan=[2,2];
    panel.ColSpan=[1,1];

    panel.Items={...
    kindLbl,kindList,...
    modeChk,...
    checkLbl,checkEdit,checkCombo,...
    statusLbl,statusList,...
    classLbl,classList,...
    commentLbl,commentTxt...
    };

    if isempty(hObj.Block)
        pageName=class(hObj);
    else
        pageName=[DAStudio.message('polyspace:gui:pslink:GUIannotTitle'),' ',hObj.Block.Name];
    end
    dlg.DialogTitle=pageName;
    dlg.LayoutGrid=[2,1];
    dlg.Items={descPanel,panel};
    dlg.PreApplyCallback='pslink.BlockAnnotation.dialogControl';
    dlg.PreApplyArgs={hObj,'%dialog','preApply'};
    dlg.PostApplyCallback='pslink.BlockAnnotation.dialogControl';
    dlg.PostApplyArgs={hObj,'%dialog','postApply'};
    dlg.HelpMethod='pslink.BlockAnnotation.dialogControl';
    dlg.HelpArgs={hObj,'%dialog','help'};



