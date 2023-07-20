function dlgstruct=imageddg(h,name)







    fixedSize.Type='checkbox';
    fixedSize.Name=DAStudio.message('Simulink:dialog:AnnotationFixedSizeName');
    fixedSize.Tag='fixedSize';
    fixedSize.Value=strcmp(h.FixedHeight,'on')||strcmp(h.FixedWidth,'on');
    fixedSize.ListenToProperties={'FixedWidth','FixedHeight','Position'};
    fixedSize.RowSpan=[1,1];
    fixedSize.ColSpan=[1,1];

    dropShadow.Type='checkbox';
    dropShadow.Name=DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
    dropShadow.Tag='dropShadow';
    dropShadow.ObjectProperty='DropShadow';
    dropShadow.RowSpan=[2,2];
    dropShadow.ColSpan=[1,1];

    appearanceGroup.Type='group';
    appearanceGroup.Name=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupName');
    appearanceGroup.Tag='AppearanceGroup';
    appearanceGroup.Flat=false;
    appearanceGroup.Items={fixedSize,dropShadow};
    appearanceGroup.LayoutGrid=[2,1];
    appearanceGroup.RowSpan=[1,1];
    appearanceGroup.ColSpan=[1,1];




    clickDesc.Type='text';
    clickDesc.Name=[DAStudio.message('Simulink:dialog:AnnotationImageClickDescNamePartOne'),10,...
    DAStudio.message('Simulink:dialog:AnnotationImageClickDescNamePartTwo')];
    clickDesc.WordWrap=true;
    clickDesc.RowSpan=[1,1];
    clickDesc.ColSpan=[1,1];

    clickFcnEdit.Type='editarea';
    clickFcnEdit.Name='';
    clickFcnEdit.Tag='clickFcnEdit';
    clickFcnEdit.ObjectProperty='ClickFcn';
    prevClickFcn=h.ClickFcn;
    clickFcnEdit.UserData=prevClickFcn;
    clickFcnEdit.Enabled=~strcmp(h.UseDisplayTextAsClickCallback,'on');
    clickFcnEdit.RowSpan=[2,2];
    clickFcnEdit.ColSpan=[1,1];

    activeGroup.Type='group';
    activeGroup.Name=DAStudio.message('Simulink:dialog:AnnotationActiveGroupName');
    activeGroup.Tag='ActiveGroup';
    activeGroup.Flat=false;
    activeGroup.Items={clickDesc,clickFcnEdit};
    activeGroup.LayoutGrid=[2,1];
    activeGroup.RowSpan=[2,2];
    activeGroup.ColSpan=[1,1];




    generalTab.Name=DAStudio.message('Simulink:dialog:AnnotationGeneralTabName');
    generalTab.Items={appearanceGroup,activeGroup};
    generalTab.LayoutGrid=[2,1];
    generalTab.RowStretch=[0,1];




    tabContainer.Name='Tabs';
    tabContainer.Type='tab';
    tabContainer.Tabs={generalTab};

    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:AnnotationTitleImage');
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'image_props_dlg'};
    dlgstruct.LayoutGrid=[1,1];
    dlgstruct.PreApplyCallback='imageddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','doApply'};
    dlgstruct.MinimalApply=true;
    dlgstruct.Items={tabContainer};
    dlgstruct.DialogTag=name;

    parent=get_param(h.Parent,'Object');
    if strcmp(get_param(bdroot(parent.Handle),'Lock'),'on')||...
        ((~isa(parent,'Simulink.BlockDiagram'))&&...
        (strcmp(parent.StaticLinkStatus,'implicit')||...
        strcmp(parent.StaticLinkStatus,'resolved')))
        dlgstruct.DisableDialog=true;
    end

