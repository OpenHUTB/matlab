function dlgstruct=slimboxddg(h,name)%#ok







    nameEdit.Type='edit';
    nameEdit.Tag='Name';
    nameEdit.Name=DAStudio.message('Simulink:dialog:AreaAnnotationObjectName');
    nameEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    nameEdit.ObjectProperty='Name';
    nameEdit.MatlabMethod='slimboxddg_cb';
    nameEdit.MatlabArgs={'%dialog','%source','%tag','%value'};






    dropShadow.Type='checkbox';
    dropShadow.Name=DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
    dropShadow.ObjectProperty='DropShadow';
    dropShadow.Tag=dropShadow.ObjectProperty;
    dropShadow.MatlabMethod='slimboxddg_cb';
    dropShadow.MatlabArgs={'%dialog','%source','%tag','%value'};

    fontLabel.Type='text';
    fontLabel.Name=DAStudio.message('Simulink:studio:SetFont');
    fontLabel.RowSpan=[1,1];
    fontLabel.ColSpan=[1,1];

    font.Type='pushbutton';
    font.Name=DAStudio.message('Simulink:dialog:AnnotationFontName');
    font.Tag='Font';
    font.RowSpan=[1,1];
    font.ColSpan=[2,2];
    font.MatlabMethod='slimboxddg_cb';
    font.MatlabArgs={'%dialog','%source','%tag',0};

    areaColorLabel.Type='text';
    areaColorLabel.Buddy='foreground';
    areaColorLabel.Name=DAStudio.message('Simulink:dialog:AnnotationForegroundName');
    areaColorLabel.WordWrap=false;
    areaColorLabel.RowSpan=[2,2];
    areaColorLabel.ColSpan=[1,1];

    areaColor.Type='combobox';
    areaColor.Name='';
    areaColor.Tag='AreaColor';
    areaColor.Entries=getColorNames();
    areaColor.Value=colorPropNameIndex(h.ForegroundColor);
    areaColor.RowSpan=[2,2];
    areaColor.ColSpan=[2,2];
    areaColor.MatlabMethod='slimboxddg_cb';
    areaColor.MatlabArgs={'%dialog','%source','%tag','%value'};

    areaColorDummy.Type='checkbox';
    areaColorDummy.ObjectProperty='ForegroundColor';
    areaColorDummy.Visible=false;

    fontColorPanel.Type='panel';
    fontColorPanel.Tag='FontColorPanel';
    fontColorPanel.LayoutGrid=[2,2];
    fontColorPanel.ColStretch=[0,1];
    fontColorPanel.Items={fontLabel,font,areaColorLabel,areaColor,areaColorDummy};


    formatPanel.Type='togglepanel';
    formatPanel.Tag='formatPanel';
    formatPanel.Expand=true;
    formatPanel.Name=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatPanel.ToolTip=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatPanel.Items={dropShadow,fontColorPanel};




    descriptionEditArea.Type='editarea';
    descriptionEditArea.ObjectProperty='Description';
    descriptionEditArea.Tag=descriptionEditArea.ObjectProperty;
    descriptionEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    descriptionEditArea.PreferredSize=[200,120];
    descriptionEditArea.MatlabMethod='slimboxddg_cb';
    descriptionEditArea.MatlabArgs={'%dialog','%source','%tag','%value'};

    descriptionPanel.Type='togglepanel';
    descriptionPanel.Name=DAStudio.message('Simulink:dialog:AreaAnnotationDescriptionPanel');
    descriptionPanel.Tag='DescriptionPanel';
    descriptionPanel.Expand=true;
    descriptionPanel.Items={descriptionEditArea};



    mainPanel.Type='panel';
    mainPanel.Tag='MainPanel';
    mainPanel.Items={nameEdit,formatPanel,descriptionPanel};
    mainPanel.RowSpan=[1,1];
    mainPanel.ColSpan=[1,1];




    spacer.Type='panel';
    spacer.Enabled=0;
    spacer.RowSpan=[2,3];
    spacer.ColSpan=[1,1];

    if slreq.utils.isInPerspective(h.Handle)

        linkInfoPanel=slreq.gui.slimInfoDDG(h.Handle);
        linkInfoPanel.RowSpan=[2,2];
        linkInfoPanel.ColSpan=[1,1];
        spacer.RowSpan=[3,3];
    else
        linkInfoPanel=struct('Type','panel');
    end





    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=name;
    dlgstruct.DialogMode='Slim';
    dlgstruct.Items={mainPanel,linkInfoPanel,spacer};
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
    dlgstruct.DisableDialog=h.isHierarchySimulating;

    parent=get_param(h.Parent,'Object');
    if strcmp(get_param(bdroot(parent.Handle),'Lock'),'on')||...
        ((~isa(parent,'Simulink.BlockDiagram'))&&...
        (strcmp(parent.StaticLinkStatus,'implicit')||...
        strcmp(parent.StaticLinkStatus,'resolved')))
        dlgstruct.DisableDialog=true;
    end
end

function colorMap=getColorMap()
    colorMap={'Brown','[0.972549, 0.952941, 0.929412]';...
    'Cyan','[0.901961, 0.960784, 1.000000]';...
    'Gray','[0.952941, 0.952941, 0.952941]';...
    'Green','[0.956863, 0.980392, 0.921569]';...
    'Magenta','[0.968627, 0.925490, 0.976471]';...
    'Red','[0.992157, 0.937255, 0.913725]';...
    'Violet','[0.901961, 0.901961, 1.000000]';...
    'Yellow','[0.996078, 0.968627, 0.909804]';...
    'Custom','[-1 -1 -1]';};
end
function names=getColorNames()
    colorMap=getColorMap();
    names=colorMap(:,1);
    for i=1:length(names)
        names{i}=DAStudio.message(['Simulink:dialog:Color',names{i}]);
    end
end

function index=colorPropNameIndex(color)
    colorMap=getColorMap();
    colorValues=colorMap(:,2);
    index=find(strcmp(colorValues',color))-1;
    if isempty(index)
        index=find(strcmp(colorValues','[-1 -1 -1]'))-1;
    end
end
