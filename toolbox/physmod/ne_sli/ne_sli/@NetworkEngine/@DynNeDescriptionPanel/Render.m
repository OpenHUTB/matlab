function[retStatus,schema]=Render(hThis,~)












    retStatus=true;
    viewSourceLabel=hThis.Label;

    textLabel.Name=pm.sli.internal.resolveMessageString(...
    hThis.DescrText);

    textLabel.Type='text';
    textLabel.WordWrap=true;
    textLabel.RowSpan=[1,1];
    textLabel.ColSpan=[1,3];
    textLabel.Tag='ComponentDescription';

    linkWidget.Type='hyperlink';
    linkWidget.Name=viewSourceLabel;
    linkWidget.Source=hThis;
    linkWidget.ToolTip=getString(...
    message('physmod:ne_sli:dialog:OpenSourceToolTip'));
    linkWidget.Tag='ViewSource';
    linkWidget.HideName=false;
    linkWidget.Mode=true;
    linkWidget.ObjectMethod='viewSource';
    linkWidget.RowSpan=[2,2];
    linkWidget.ColSpan=[1,1];


    selectSource.Type='pushbutton';
    selectSource.Name=getString(...
    message('physmod:ne_sli:dialog:ChooseSourceString'));
    selectSource.Source=hThis;
    selectSource.ToolTip=getString(...
    message('physmod:ne_sli:dialog:ChooseSourceToolTip'));
    selectSource.Tag='ChooseSource';
    selectSource.HideName=false;
    selectSource.Mode=true;
    selectSource.ObjectMethod='chooseSource';
    selectSource.MethodArgs={'%dialog'};
    selectSource.ArgDataTypes={'handle'};
    selectSource.DialogRefresh=true;

    selectSource.RowSpan=[2,2];
    selectSource.ColSpan=[3,3];


    hBlk=pmsl_getdoublehandle(hThis.BlockHandle);
    showWidget=nesl_private('nesl_showsourcewidget');
    linkWidget.Visible=showWidget(hBlk);


    showSelect=simscape.engine.sli.internal.iscomponentblock(hBlk)&&...
    isempty(get_param(hBlk,'ReferenceBlock'));
    selectSource.Visible=showSelect;


    lablStr=pm.sli.internal.cleanGroupLabel(...
    pm.sli.internal.resolveMessageString(hThis.BlockTitle));

    grpBox.Name=lablStr;
    grpBox.Type='group';
    grpBox.RowSpan=[1,1];
    grpBox.ColSpan=[1,1];
    grpBox.LayoutGrid=[2,3];
    grpBox.ColStretch=[0,1,0];
    grpBox.Items={textLabel,linkWidget,selectSource};
    grpBox.Tag='ComponentDescriptionGroup';

    schema=grpBox;
end



