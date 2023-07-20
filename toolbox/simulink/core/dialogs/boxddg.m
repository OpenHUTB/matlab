function dlgstruct=boxddg(h,name)%#ok





    tabContainer.Name='Tabs';
    tabContainer.Type='tab';
    tabContainer.Tabs={createGeneralTab(h)};
    tabContainer.LayoutGrid=[1,1];

    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:AreaAnnotationTitlePartial',strtok(h.PlainText,char(10)));
    dlgstruct.HelpMethod='helpview';


    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'annotation_props_dlg'};

    dlgstruct.MinimalApply=true;
    dlgstruct.DialogRefresh=true;
    dlgstruct.Items={tabContainer};
    dlgstruct.DialogTag=name;

    parent=get_param(h.Parent,'Object');
    if strcmp(get_param(bdroot(parent.Handle),'Lock'),'on')||...
        ((~isa(parent,'Simulink.BlockDiagram'))&&...
        (strcmp(parent.StaticLinkStatus,'implicit')||...
        strcmp(parent.StaticLinkStatus,'resolved')))
        dlgstruct.DisableDialog=true;
    end
end

function generalTab=createGeneralTab(h)

    nameEditArea.Type='edit';
    nameEditArea.Tag='NameEditArea';
    nameEditArea.Name=DAStudio.message('Simulink:dialog:ObjectNamePrompt');
    nameEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    nameEditArea.ObjectProperty='Name';
    nameEditArea.RowSpan=[1,1];
    nameEditArea.ColSpan=[1,1];

    descriptionEditArea.Type='editarea';
    descriptionEditArea.Tag='DescriptionEditArea';
    descriptionEditArea.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descriptionEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    descriptionEditArea.ObjectProperty='Description';
    descriptionEditArea.RowSpan=[2,1];
    descriptionEditArea.ColSpan=[1,1];

    generalGroup.Type='group';
    generalGroup.Tag='GeneralGroup';
    generalGroup.Items={nameEditArea,descriptionEditArea};
    generalGroup.LayoutGrid=[2,1];
    generalGroup.RowStretch=[0,1];
    generalGroup.ColStretch=1;





    fontLabel.Type='text';
    fontLabel.Name=DAStudio.message('Simulink:studio:SetFont');
    fontLabel.WordWrap=false;
    fontLabel.RowSpan=[4,4];
    fontLabel.ColSpan=[1,1];

    font.Type='pushbutton';
    font.Name=DAStudio.message('Simulink:dialog:AnnotationFontName');
    font.Tag='font';
    font.ObjectMethod='showFontDialog';
    font.RowSpan=[4,4];
    font.ColSpan=[2,2];

    formatGroup.Type='group';
    formatGroup.Name=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatGroup.Tag='FormatGroup';
    formatGroup.Flat=false;
    formatGroup.Items={fontLabel,font};
    formatGroup.LayoutGrid=[4,3];
    formatGroup.ColStretch=[0,0,1];
    formatGroup.ColSpan=[1,1];
    formatGroup.RowSpan=[2,2];





    generalTab.Name=DAStudio.message('Simulink:dialog:AnnotationGeneralTabName');
    generalTab.Items={generalGroup,formatGroup};
    generalTab.LayoutGrid=[2,1];
    generalTab.RowStretch=[0,1];
end

