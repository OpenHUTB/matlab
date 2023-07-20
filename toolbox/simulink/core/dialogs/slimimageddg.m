function dlgstruct=slimimageddg(h,name)







    dropShadow.Type='checkbox';
    dropShadow.Name=DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
    dropShadow.ObjectProperty='DropShadow';
    dropShadow.Tag=dropShadow.ObjectProperty;
    dropShadow.MatlabMethod='slimimageddg_cb';
    dropShadow.MatlabArgs={'%dialog','%source','%tag','%value'};

    appearancePanel.Type='togglepanel';
    appearancePanel.Name=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupName');
    appearancePanel.Tag='AppearancePanel';
    appearancePanel.Expand=true;
    appearancePanel.Items={dropShadow};




    clickDesc.Type='text';
    clickDesc.Name=[DAStudio.message('Simulink:dialog:AnnotationImageClickDescNamePartOne'),10,...
    DAStudio.message('Simulink:dialog:AnnotationImageClickDescNamePartTwo')];
    clickDesc.WordWrap=true;

    clickFcnEdit.Type='editarea';
    clickFcnEdit.Name='';
    clickFcnEdit.ObjectProperty='ClickFcn';
    clickFcnEdit.Tag=clickFcnEdit.ObjectProperty;
    clickFcnEdit.Enabled=~strcmp(h.UseDisplayTextAsClickCallback,'on');
    clickFcnEdit.PreferredSize=[200,80];
    clickFcnEdit.MatlabMethod='slimimageddg_cb';
    clickFcnEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    clickFcnDummy.Type='checkbox';
    clickFcnDummy.Tag='ClickFcnDummy';
    clickFcnDummy.ObjectProperty='UseDisplayTextAsClickCallback';
    clickFcnDummy.Visible=false;

    activePanel.Type='togglepanel';
    activePanel.Name=DAStudio.message('Simulink:dialog:AnnotationActiveGroupName');
    activePanel.Tag='ActiveGroup';
    activePanel.Items={clickDesc,clickFcnEdit,clickFcnDummy};




    generalPanel.Type='panel';
    generalPanel.Name=DAStudio.message('Simulink:dialog:AnnotationGeneralTabName');
    generalPanel.Items={appearancePanel,activePanel};




    spacer.Type='panel';
    spacer.Enabled=0;
    spacer.RowSpan=[2,3];




    if slreq.utils.isInPerspective(h.Handle)

        linkInfoPanel=slreq.gui.slimInfoDDG(h.Handle);
        linkInfoPanel.RowSpan=[2,2];
        linkInfoPanel.ColSpan=[1,1];
        spacer.RowSpan=[3,3];
    else
        linkInfoPanel=struct('Type','panel');
    end




    dlgstruct.DialogMode='Slim';
    dlgstruct.DialogTitle='';
    dlgstruct.LayoutGrid=[3,1];
    dlgstruct.RowStretch=[0,0,1];
    dlgstruct.Items={generalPanel,linkInfoPanel,spacer};
    dlgstruct.DialogTag=name;
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.DisableDialog=h.isHierarchySimulating;

    parent=get_param(h.Parent,'Object');
    if strcmp(get_param(bdroot(parent.Handle),'Lock'),'on')||...
        ((~isa(parent,'Simulink.BlockDiagram'))&&...
        (strcmp(parent.StaticLinkStatus,'implicit')||...
        strcmp(parent.StaticLinkStatus,'resolved')))
        dlgstruct.DisableDialog=true;
    end
end
