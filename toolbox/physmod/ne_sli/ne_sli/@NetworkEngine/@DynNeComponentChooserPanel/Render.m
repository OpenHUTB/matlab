function[retVal,schema]=Render(hThis,schema)%#ok<INUSD>












    retVal=true;
    descriptionTag='ComponentDescription';
    descriptionPanelTag='ComponentDescriptionPanel';


    edit1.Type='edit';
    edit1.ObjectProperty='ComponentName';
    edit1.Tag='ComponentName';
    edit1.Source=hThis;
    edit1.ColSpan=[1,1];
    edit1.RowSpan=[1,1];
    edit1.Mode=true;
    edit1.Enabled=hThis.Enabled;


    browseButton.Type='pushbutton';
    browseButton.Tag='browseSource';
    browseButton.ObjectMethod='BrowseSource';
    browseButton.MethodArgs={'%dialog'};
    browseButton.ArgDataTypes={'handle'};
    browseButton.Source=hThis;
    browseButton.ColSpan=[2,2];
    browseButton.RowSpan=[1,1];
    browseButton.ToolTip=getString(...
    message('physmod:ne_sli:dialog:BrowseSourceToolTip'));
    browseButton.FilePath=...
    fullfile(matlabroot,'toolbox','physmod','ne_sli','ne_sli','internal','resources','open.png');
    browseButton.Enabled=hThis.Enabled;


    refreshButton.Type='pushbutton';
    refreshButton.Tag='refreshSource';
    refreshButton.ObjectMethod='RefreshSource';
    refreshButton.MethodArgs={'%dialog',descriptionTag,descriptionPanelTag};
    refreshButton.ArgDataTypes={'handle','ustring','ustring'};
    refreshButton.Source=hThis;
    refreshButton.ColSpan=[3,3];
    refreshButton.RowSpan=[1,1];
    refreshButton.ToolTip=getString(...
    message('physmod:ne_sli:dialog:RefreshSourceToolTip'));
    refreshButton.FilePath=...
    fullfile(matlabroot,'toolbox','physmod','ne_sli','ne_sli','internal','resources','refresh.png');

    titleTxt=pm.sli.internal.cleanGroupLabel(hThis.ComponentTitle);
    descriptionTxt=hThis.ComponentDescription;

    description.Type='text';
    description.Name=descriptionTxt;
    description.Tag=descriptionTag;
    description.Editable=false;
    description.WordWrap=true;
    description.RowSpan=[1,1];
    description.ColSpan=[1,3];
    description.Alignment=8;

    linkWidget.Type='hyperlink';
    linkWidget.Name=getString(...
    message('physmod:ne_sli:dialog:OpenSourceString'));
    linkWidget.Source=hThis;
    linkWidget.ToolTip=getString(...
    message('physmod:ne_sli:dialog:OpenSourceToolTip'));
    linkWidget.Tag='ViewSource';
    linkWidget.HideName=false;
    linkWidget.RowSpan=[2,2];
    linkWidget.ColSpan=[1,1];
    linkWidget.ObjectMethod='viewSource';
    linkWidget.Visible=~isempty(which(hThis.ComponentName));

    viewParameters.Type='pushbutton';
    viewParameters.Name='';
    viewParameters.Source=hThis;
    viewParameters.ToolTip=getString(...
    message('physmod:ne_sli:dialog:ViewParametersToolTip'));
    viewParameters.Tag='ViewParameters';
    viewParameters.HideName=false;
    viewParameters.ObjectMethod='viewParameters';
    viewParameters.MethodArgs={'%dialog'};
    viewParameters.ArgDataTypes={'handle'};
    viewParameters.FilePath=...
    fullfile(matlabroot,'toolbox','physmod','ne_sli','ne_sli','internal','resources','viewparams.png');

    viewParameters.RowSpan=[1,1];
    viewParameters.ColSpan=[4,4];

    descriptionPanel.Type='group';
    descriptionPanel.Tag=descriptionPanelTag;
    descriptionPanel.Items={description,linkWidget};
    descriptionPanel.Alignment=0;
    descriptionPanel.ColStretch=[0,1,0];
    descriptionPanel.LayoutGrid=[2,3];
    descriptionPanel.Name=titleTxt;


    chooserPanel.Type='panel';
    chooserPanel.Items={edit1,browseButton,refreshButton,viewParameters};
    chooserPanel.LayoutGrid=[3,1];
    chooserPanel.RowStretch=[0,0,1];
    dlgPanel.Alignment=0;
    dlgPanel.Type='panel';
    dlgPanel.Items={descriptionPanel,chooserPanel};
    dlgPanel.LayoutGrid=[2,1];
    dlgPanel.RowStretch=[0,1];
    schema=dlgPanel;

end
