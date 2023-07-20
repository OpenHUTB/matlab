function dlgStruct=nesl_create_errorschema(hBlk,errorStr)





    dlgStruct.DialogTitle=getString(...
    message('physmod:pm_sli:dialog:ErrorDlgTitle'));
    dlgStruct.Items={lCombined(errorStr)};
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.CloseMethod='closeDialogCB';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    dlgStruct.RowStretch=[0,1];
    dlgStruct.LayoutGrid=[2,1];

    try
        showSource=nesl_private('nesl_showsourcewidget');
        if showSource(hBlk)
            dlgStruct.RowStretch=[0,0,1];
            dlgStruct.LayoutGrid=[3,1];
            dlgStruct.Items=[dlgStruct.Items,lLinkWidget(hBlk)];
        end
    catch
    end

end

function p=lCombined(errorStr)
    p.Type='panel';
    p.LayoutGrid=[1,2];
    p.ColStretch=[0,1];
    p.Items={lErrorIcon(),lErrorField(errorStr)};
end

function i=lErrorIcon()
    i.Type='image';
    i.FilePath=fullfile(pmsl_dialogresourcedir,'error.png');
    i.RowSpan=[1,1];
    i.Alignment=2;
end

function t=lErrorField(errorStr)
    t.Type='text';
    t.Name=errorStr;
    t.WordWrap=true;
    t.RowSpan=[2,2];
    t.Tag='ErrorMessage';
end

function linkWidget=lLinkWidget(hBlk)
    linkWidget.Type='hyperlink';
    linkWidget.Name=getString(...
    message('physmod:ne_sli:dialog:OpenSourceString'));
    linkWidget.ToolTip=getString(...
    message('physmod:ne_sli:dialog:OpenSourceToolTip'));
    linkWidget.Tag='ViewSource';
    linkWidget.HideName=false;
    linkWidget.MatlabMethod='simscape.internal.viewsource';
    linkWidget.MatlabArgs={hBlk};
    linkWidget.RowSpan=[3,3];
    linkWidget.Alignment=3;
end