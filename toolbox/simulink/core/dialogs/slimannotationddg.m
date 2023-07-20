function dlgstruct=slimannotationddg(h,name)


    general=createPanel(h);
    general.RowSpan=[1,1];
    general.ColSpan=[1,1];
    general.Name='';
    general.Type='panel';

    spacer.Type='panel';
    spacer.Enabled=0;
    spacer.RowSpan=[2,2];
    spacer.ColSpan=[1,1];




    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=name;
    dlgstruct.DialogMode='Slim';
    dlgstruct.Items={general,spacer};
    dlgstruct.LayoutGrid=[2,1];
    dlgstruct.RowStretch=[0,1];
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


function generalPanel=createPanel(h)



    fixedHeight.Type='checkbox';
    fixedHeight.Name=DAStudio.message('Simulink:dialog:AnnotationFixedHeightName');
    fixedHeight.ObjectProperty='FixedHeight';
    fixedHeight.Tag=fixedHeight.ObjectProperty;
    fixedHeight.RowSpan=[1,1];
    fixedHeight.ColSpan=[1,1];
    fixedHeight.MatlabMethod='slimannotationddg_cb';
    fixedHeight.MatlabArgs={'%dialog','%source','%tag','%value'};

    fixedWidth.Type='checkbox';
    fixedWidth.Name=DAStudio.message('Simulink:dialog:AnnotationFixedWidthName');
    fixedWidth.ObjectProperty='FixedWidth';
    fixedWidth.Tag=fixedWidth.ObjectProperty;
    fixedWidth.RowSpan=[2,2];
    fixedWidth.ColSpan=[1,1];
    fixedWidth.MatlabMethod='slimannotationddg_cb';
    fixedWidth.MatlabArgs={'%dialog','%source','%tag','%value'};

    dropShadow.Type='checkbox';
    dropShadow.Name=DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
    dropShadow.ObjectProperty='DropShadow';
    dropShadow.Tag=dropShadow.ObjectProperty;
    dropShadow.RowSpan=[1,1];
    dropShadow.ColSpan=[2,2];
    dropShadow.MatlabMethod='slimannotationddg_cb';
    dropShadow.MatlabArgs={'%dialog','%source','%tag','%value'};

    interpretMode.Type='checkbox';
    interpretMode.Name=DAStudio.message('Simulink:dialog:AnnotationTexModeName');
    interpretMode.Tag='Interpreter';
    interpretMode.Value=strcmp(h.Interpreter,'tex');
    interpretMode.RowSpan=[2,2];
    interpretMode.ColSpan=[2,2];
    interpretMode.MatlabMethod='slimannotationddg_cb';
    interpretMode.MatlabArgs={'%dialog','%source','%tag','%value'};

    interpretDummy.Type='edit';
    interpretDummy.Tag='InterpretDummy';
    interpretDummy.ObjectProperty='Interpreter';
    interpretDummy.Visible=0;

    appearancePanel.Type='togglepanel';
    appearancePanel.Expand=true;
    appearancePanel.Name=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupName');
    appearancePanel.ToolTip=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupToolTip');
    appearancePanel.Tag='AppearanceGroup';
    appearancePanel.Items={fixedHeight,fixedWidth,dropShadow,interpretMode,interpretDummy};
    appearancePanel.LayoutGrid=[2,2];
    appearancePanel.ColStretch=[1,1];




    foregroundLabel.Type='text';
    foregroundLabel.Name=DAStudio.message('Simulink:dialog:AnnotationForegroundName');
    foregroundLabel.RowSpan=[1,1];
    foregroundLabel.ColSpan=[1,1];

    foreground.Type='combobox';
    foreground.Name='';
    foreground.Tag='ForegroundColor';
    foreground.Entries=getColorNames(false);
    foreground.Value=colorPropNameIndex(h.ForegroundColor,false);
    foreground.RowSpan=[1,1];
    foreground.ColSpan=[2,2];
    foreground.MatlabMethod='slimannotationddg_cb';
    foreground.MatlabArgs={'%dialog','%source','%tag','%value'};

    foregroundDummy.Type='edit';
    foregroundDummy.Tag='ForegroundDummy';
    foregroundDummy.ObjectProperty='ForegroundColor';
    foregroundDummy.Visible=0;

    backgroundLabel.Type='text';
    backgroundLabel.Name=DAStudio.message('Simulink:dialog:AnnotationBackgroundName');
    backgroundLabel.RowSpan=[2,2];
    backgroundLabel.ColSpan=[1,1];

    background.Type='combobox';
    background.Name='';
    background.Tag='BackgroundColor';
    background.Entries=getColorNames(true);
    background.Value=colorPropNameIndex(h.BackgroundColor,true);
    background.RowSpan=[2,2];
    background.ColSpan=[2,2];
    background.MatlabMethod='slimannotationddg_cb';
    background.MatlabArgs={'%dialog','%source','%tag','%value'};

    backgroundDummy.Type='edit';
    backgroundDummy.ObjectProperty='BackgroundColor';
    backgroundDummy.Visible=0;
    backgroundDummy.Tag='BackgroundDummy';

    alignmentLabel.Type='text';
    alignmentLabel.Name=DAStudio.message('Simulink:dialog:AnnotationAlignmentName');
    alignmentLabel.RowSpan=[3,3];
    alignmentLabel.ColSpan=[1,1];

    alignment.Type='combobox';
    alignment.Name='';
    alignment.Tag='HorizontalAlignment';
    alignment.Entries={DAStudio.message('Simulink:dialog:TextAlignmentLeft'),...
    DAStudio.message('Simulink:dialog:TextAlignmentCenter'),...
    DAStudio.message('Simulink:dialog:TextAlignmentRight')};
    alignment.Value=alignmentPropNameIndex(h.HorizontalAlignment);
    alignment.RowSpan=[3,3];
    alignment.ColSpan=[2,2];
    alignment.MatlabMethod='slimannotationddg_cb';
    alignment.MatlabArgs={'%dialog','%source','%tag','%value'};

    alignDummy.Type='edit';
    alignDummy.Tag='AlignDummy';
    alignDummy.ObjectProperty='HorizontalAlignment';
    alignDummy.Visible=0;

    fontLabel.Type='text';
    fontLabel.Name=DAStudio.message('Simulink:dialog:AnnotationDefaultFontName');
    fontLabel.WordWrap=false;
    fontLabel.RowSpan=[4,4];
    fontLabel.ColSpan=[1,1];

    font.Type='pushbutton';
    font.Name=DAStudio.message('Simulink:dialog:AnnotationFontName');
    font.Tag='Font';
    font.RowSpan=[4,4];
    font.ColSpan=[2,2];
    font.MatlabMethod='slimannotationddg_cb';
    font.MatlabArgs={'%dialog','%source','%tag',0};

    formatPanle.Type='togglepanel';
    formatPanle.Expand=true;
    formatPanle.Name=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatPanle.ToolTip=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatPanle.Tag='FormatPanel';
    formatPanle.Items={foregroundLabel,foreground,foregroundDummy,backgroundLabel,background,backgroundDummy,alignmentLabel,alignment,alignDummy,fontLabel,font};
    formatPanle.LayoutGrid=[4,2];
    formatPanle.ColStretch=[0,1];




    leftMarginLabel.Type='text';
    leftMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationLeftMarginShortName');
    leftMarginLabel.RowSpan=[1,1];
    leftMarginLabel.ColSpan=[1,1];

    leftMarginEdit.Type='spinbox';
    leftMarginEdit.Range=getUnconstrainedRange(h.InternalMargins(1));
    leftMarginEdit.Tag='LeftMarginEdit';
    leftMarginEdit.Value=h.InternalMargins(1);
    leftMarginEdit.RowSpan=[1,1];
    leftMarginEdit.ColSpan=[2,2];
    leftMarginEdit.MatlabMethod='slimannotationddg_cb';
    leftMarginEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    topMarginLabel.Type='text';
    topMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationTopMarginShortName');
    topMarginLabel.RowSpan=[2,2];
    topMarginLabel.ColSpan=[1,1];

    topMarginEdit.Type='spinbox';
    topMarginEdit.Range=getUnconstrainedRange(h.InternalMargins(2));
    topMarginEdit.Tag='TopMarginEdit';
    topMarginEdit.Value=h.InternalMargins(2);
    topMarginEdit.RowSpan=[2,2];
    topMarginEdit.ColSpan=[2,2];
    topMarginEdit.MatlabMethod='slimannotationddg_cb';
    topMarginEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    rightMarginLabel.Type='text';
    rightMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationRightMarginShortName');
    rightMarginLabel.RowSpan=[1,1];
    rightMarginLabel.ColSpan=[3,3];

    rightMarginEdit.Type='spinbox';
    rightMarginEdit.Range=getUnconstrainedRange(h.InternalMargins(3));
    rightMarginEdit.Tag='RightMarginEdit';
    rightMarginEdit.Value=h.InternalMargins(3);
    rightMarginEdit.RowSpan=[1,1];
    rightMarginEdit.ColSpan=[4,4];
    rightMarginEdit.MatlabMethod='slimannotationddg_cb';
    rightMarginEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    bottomMarginLabel.Type='text';
    bottomMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationBottomMarginShortName');
    bottomMarginLabel.RowSpan=[2,2];
    bottomMarginLabel.ColSpan=[3,3];

    bottomMarginEdit.Type='spinbox';
    bottomMarginEdit.Range=getUnconstrainedRange(h.InternalMargins(4));
    bottomMarginEdit.Tag='BottomMarginEdit';
    bottomMarginEdit.Value=h.InternalMargins(4);
    bottomMarginEdit.RowSpan=[2,2];
    bottomMarginEdit.ColSpan=[4,4];
    bottomMarginEdit.MatlabMethod='slimannotationddg_cb';
    bottomMarginEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    dummyMargin.Type='spinbox';
    dummyMargin.Tag='DummyMargin';
    dummyMargin.ObjectProperty='InternalMargins';
    dummyMargin.Visible=false;

    internalMarginPanel.Type='togglepanel';
    internalMarginPanel.Expand=true;
    internalMarginPanel.Name=DAStudio.message('Simulink:dialog:AnnotationInternalMarginGroupName');
    internalMarginPanel.ToolTip=DAStudio.message('Simulink:dialog:AnnotationInternalMarginGroupToolTip');
    internalMarginPanel.Tag='InternalMarginPanel';
    internalMarginPanel.Items={leftMarginLabel,leftMarginEdit,topMarginLabel,topMarginEdit,rightMarginLabel,rightMarginEdit,bottomMarginLabel,bottomMarginEdit,dummyMargin};
    internalMarginPanel.LayoutGrid=[2,4];
    internalMarginPanel.ColStretch=[0,1,0,1];




    clickDesc.Type='text';
    clickDesc.Name=[DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartOne'),10,...
    DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartTwo')];
    clickDesc.WordWrap=true;

    useTextClickFcn.Type='checkbox';
    useTextClickFcn.Name=DAStudio.message('Simulink:dialog:AnnotationUseTextForClickFcnName');
    useTextClickFcn.ObjectProperty='UseDisplayTextAsClickCallback';
    useTextClickFcn.Tag=useTextClickFcn.ObjectProperty;
    useTextClickFcn.MatlabMethod='slimannotationddg_cb';
    useTextClickFcn.MatlabArgs={'%dialog','%source','%tag','%value'};

    clickFcnEdit.Type='editarea';
    clickFcnEdit.ObjectProperty='ClickFcn';
    clickFcnEdit.Tag=clickFcnEdit.ObjectProperty;
    clickFcnEdit.Enabled=~strcmp(h.UseDisplayTextAsClickCallback,'on');
    clickFcnEdit.PreferredSize=[200,80];
    clickFcnEdit.MatlabMethod='slimannotationddg_cb';
    clickFcnEdit.MatlabArgs={'%dialog','%source','%tag','%value'};

    activePanel.Type='togglepanel';
    activePanel.Name=DAStudio.message('Simulink:dialog:AnnotationActiveGroupName');
    activePanel.ToolTip=DAStudio.message('Simulink:dialog:AnnotationActiveGroupToolTip');
    activePanel.Tag='ActiveGroup';
    activePanel.Items={clickDesc,useTextClickFcn,clickFcnEdit};
    activePanel.Visible=~isempty(h.ClickFcn)||strcmp(h.UseDisplayTextAsClickCallback,'on');




    generalPanel.Name=DAStudio.message('Simulink:dialog:AnnotationGeneralTabName');
    generalPanel.Type='panel';
    generalPanel.Items={appearancePanel,formatPanle,internalMarginPanel,activePanel};
end

function range=getUnconstrainedRange(value)
    low=min(0,value);
    high=max(999,value);
    range=[low,high];
end

function list=getColorNameList(includeCustom,isBackground)

    if includeCustom
        list={'Custom'};
    else
        list=[];
    end
    list=[list,{...
    'Black','White','Red',...
    'Green','Blue','Yellow',...
    'Magenta','Cyan','Gray',...
    'Orange','LightBlue','DarkGreen'}];
    if isBackground
        list=[list,{'Automatic'}];
    end
end

function names=getColorNames(isBackground)

    names=getColorNameList(true,isBackground);
    for i=1:length(names)
        names{i}=DAStudio.message(['Simulink:dialog:Color',names{i}]);
    end
end

function index=colorPropNameIndex(name,isBackground)

    index=0;
    names=getColorNameList(false,isBackground);
    for k=1:length(names)
        if strcmpi(names{k},name)
            index=k;
            return;
        end
    end
end


function index=alignmentPropNameIndex(name)
    index=0;
    switch name
    case 'left'
        index=0;
    case 'center'
        index=1;
    case 'right'
        index=2;
    end
end
