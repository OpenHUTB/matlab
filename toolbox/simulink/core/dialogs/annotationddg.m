function dlgstruct=annotationddg(h,name)%#ok












    tabContainer.Name='Tabs';
    tabContainer.Type='tab';
    tabContainer.Tabs={createGeneralTab(h),createClickFcnTab(h)};
    tabContainer.LayoutGrid=[1,1];

    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:AnnotationTitlePartial',strtok(h.PlainText,char(10)));
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'annotation_props_dlg'};
    dlgstruct.PreApplyCallback='annotationddg_cb';
    dlgstruct.PreApplyArgs={'%dialog','doApply'};
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



    fixedHeight.Type='checkbox';
    fixedHeight.Name=DAStudio.message('Simulink:dialog:AnnotationFixedHeightName');
    fixedHeight.Tag='fixedHeight';
    fixedHeight.ObjectProperty='FixedHeight';
    fixedHeight.RowSpan=[1,1];
    fixedHeight.ColSpan=[1,1];

    fixedWidth.Type='checkbox';
    fixedWidth.Name=DAStudio.message('Simulink:dialog:AnnotationFixedWidthName');
    fixedWidth.Tag='fixedWidth';
    fixedWidth.ObjectProperty='FixedWidth';
    fixedWidth.RowSpan=[2,2];
    fixedWidth.ColSpan=[1,1];

    dropShadow.Type='checkbox';
    dropShadow.Name=DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
    dropShadow.Tag='dropShadow';
    dropShadow.ObjectProperty='DropShadow';
    dropShadow.RowSpan=[3,3];
    dropShadow.ColSpan=[1,1];

    interpretMode.Type='checkbox';
    interpretMode.Name=DAStudio.message('Simulink:dialog:AnnotationTexModeName');
    interpretMode.Tag='interpreter';
    interpretMode.Value=strcmp(h.Interpreter,'tex');
    interpretMode.RowSpan=[4,4];
    interpretMode.ColSpan=[1,1];

    interpretDummy.Type='edit';
    interpretDummy.Tag='InterpretDummy';
    interpretDummy.ObjectProperty='Interpreter';
    interpretDummy.Visible=0;

    appearanceGroup.Type='group';
    appearanceGroup.Name=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupName');
    appearanceGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupToolTip');
    appearanceGroup.Tag='AppearanceGroup';
    appearanceGroup.Flat=false;
    appearanceGroup.Items={fixedHeight,fixedWidth,dropShadow,interpretMode,interpretDummy};
    appearanceGroup.LayoutGrid=[4,1];
    appearanceGroup.ColSpan=[1,1];
    appearanceGroup.RowSpan=[1,1];




    foregroundLabel.Type='text';
    foregroundLabel.Name=DAStudio.message('Simulink:dialog:AnnotationForegroundName');
    foregroundLabel.WordWrap=false;
    foregroundLabel.RowSpan=[1,1];
    foregroundLabel.ColSpan=[1,1];

    foreground.Type='combobox';
    foreground.Name='';
    foreground.Tag='foreground';
    foreground.Entries=getColorNames(false);
    foreground.MatlabMethod='annotationddg_cb';
    foreground.MatlabArgs={'%dialog','doForeground'};
    fgUserData.wasSet=false;
    foreground.UserData=fgUserData;
    foreground.Value=colorPropNameIndex(h.ForegroundColor,false);
    foreground.RowSpan=[1,1];
    foreground.ColSpan=[2,2];

    foregroundDummy.Type='edit';
    foregroundDummy.Tag='ForegroundDummy';
    foregroundDummy.ObjectProperty='ForegroundColor';
    foregroundDummy.Visible=0;

    backgroundLabel.Type='text';
    backgroundLabel.Name=DAStudio.message('Simulink:dialog:AnnotationBackgroundName');
    backgroundLabel.WordWrap=false;
    backgroundLabel.RowSpan=[2,2];
    backgroundLabel.ColSpan=[1,1];

    background.Type='combobox';
    background.Name='';
    background.Tag='background';
    background.Entries=getColorNames(true);
    background.MatlabMethod='annotationddg_cb';
    background.MatlabArgs={'%dialog','doBackground'};
    bgUserData.wasSet=false;
    background.UserData=bgUserData;
    background.Value=colorPropNameIndex(h.BackgroundColor,true);
    background.RowSpan=[2,2];
    background.ColSpan=[2,2];

    backgroundDummy.Type='edit';
    backgroundDummy.ObjectProperty='BackgroundColor';
    backgroundDummy.Visible=0;
    backgroundDummy.Tag='BackgroundDummy';

    alignmentLabel.Type='text';
    alignmentLabel.Name=DAStudio.message('Simulink:dialog:AnnotationAlignmentName');
    alignmentLabel.WordWrap=false;
    alignmentLabel.RowSpan=[3,3];
    alignmentLabel.ColSpan=[1,1];

    alignment.Type='combobox';
    alignment.Name='';
    alignment.Tag='alignment';
    alignment.Entries={DAStudio.message('Simulink:dialog:TextAlignmentLeft'),...
    DAStudio.message('Simulink:dialog:TextAlignmentCenter'),...
    DAStudio.message('Simulink:dialog:TextAlignmentRight')};
    alignment.Value=alignmentPropNameIndex(h.HorizontalAlignment);
    alignment.RowSpan=[3,3];
    alignment.ColSpan=[2,2];

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
    font.Tag='font';
    font.ObjectMethod='showFontDialog';
    font.RowSpan=[4,4];
    font.ColSpan=[2,2];

    formatGroup.Type='group';
    formatGroup.Name=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationFormatGroupName');
    formatGroup.Tag='FormatGroup';
    formatGroup.Flat=false;
    formatGroup.Items={foregroundLabel,foreground,foregroundDummy,backgroundLabel,background,backgroundDummy,alignmentLabel,alignment,alignDummy,fontLabel,font};
    formatGroup.LayoutGrid=[4,3];
    formatGroup.ColStretch=[0,0,1];
    formatGroup.ColSpan=[1,1];
    formatGroup.RowSpan=[2,2];




    leftMarginLabel.Type='text';
    leftMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationLeftMarginName');
    leftMarginLabel.WordWrap=false;
    leftMarginLabel.RowSpan=[1,1];
    leftMarginLabel.ColSpan=[1,1];

    leftMarginEdit.Type='edit';
    leftMarginEdit.Name='';
    leftMarginEdit.Tag='LeftMarginEdit';
    leftMarginEdit.RowSpan=[1,1];
    leftMarginEdit.ColSpan=[2,2];
    leftMarginEdit.Value=h.InternalMargins(1);

    topMarginLabel.Type='text';
    topMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationTopMarginName');
    topMarginLabel.WordWrap=false;
    topMarginLabel.RowSpan=[2,2];
    topMarginLabel.ColSpan=[1,1];

    topMarginEdit.Type='edit';
    topMarginEdit.Name='';
    topMarginEdit.Tag='TopMarginEdit';
    topMarginEdit.Value=h.InternalMargins(2);
    topMarginEdit.RowSpan=[2,2];
    topMarginEdit.ColSpan=[2,2];

    rightMarginLabel.Type='text';
    rightMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationRightMarginName');
    rightMarginLabel.WordWrap=false;
    rightMarginLabel.RowSpan=[3,3];
    rightMarginLabel.ColSpan=[1,1];

    rightMarginEdit.Type='edit';
    rightMarginEdit.Name='';
    rightMarginEdit.Tag='RightMarginEdit';
    rightMarginEdit.Value=h.InternalMargins(3);
    rightMarginEdit.RowSpan=[3,3];
    rightMarginEdit.ColSpan=[2,2];

    bottomMarginLabel.Type='text';
    bottomMarginLabel.Name=DAStudio.message('Simulink:dialog:AnnotationBottomMarginName');
    bottomMarginLabel.WordWrap=false;
    bottomMarginLabel.RowSpan=[4,4];
    bottomMarginLabel.ColSpan=[1,1];

    bottomMarginEdit.Type='edit';
    bottomMarginEdit.Name='';
    bottomMarginEdit.Tag='BottomMarginEdit';
    bottomMarginEdit.Value=h.InternalMargins(4);
    bottomMarginEdit.RowSpan=[4,4];
    bottomMarginEdit.ColSpan=[2,2];

    internalMarginGroup.Type='group';
    internalMarginGroup.Name=DAStudio.message('Simulink:dialog:AnnotationInternalMarginGroupName');
    internalMarginGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationInternalMarginGroupToolTip');
    internalMarginGroup.Tag='InternalMarginGroup';
    internalMarginGroup.Flat=false;
    internalMarginGroup.Items={leftMarginLabel,leftMarginEdit,topMarginLabel,topMarginEdit,rightMarginLabel,rightMarginEdit,bottomMarginLabel,bottomMarginEdit};
    internalMarginGroup.LayoutGrid=[4,3];
    internalMarginGroup.ColStretch=[0,0,1];
    internalMarginGroup.ColSpan=[1,1];
    internalMarginGroup.RowSpan=[3,3];




    generalTab.Name=DAStudio.message('Simulink:dialog:AnnotationGeneralTabName');
    generalTab.Items={appearanceGroup,formatGroup,internalMarginGroup};
    generalTab.LayoutGrid=[2,1];
    generalTab.RowStretch=[0,1];
end

function clickFcnTab=createClickFcnTab(h)



    textEdit.Type='editarea';
    textEdit.Name='';
    textEdit.Tag='text';
    textEdit.Value=h.PlainText;
    textEdit.MaximumSize=[5000,80];
    textEdit.RowSpan=[1,1];
    textEdit.ColSpan=[1,1];
    textEdit.Enabled=~strcmp(h.Interpreter,'rich');

    textGroup.Type='group';
    textGroup.Name=DAStudio.message('Simulink:dialog:AnnotationTextGroupName');
    textGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationTextGroupToolTip');
    textGroup.Tag='TextGroup';
    textGroup.Flat=false;
    textGroup.Items={textEdit};
    textGroup.LayoutGrid=[1,1];
    textGroup.ColSpan=[1,1];
    textGroup.RowSpan=[1,1];




    clickDesc.Type='text';
    clickDesc.Name=[DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartOne'),10,...
    DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartTwo')];
    clickDesc.WordWrap=true;
    clickDesc.RowSpan=[1,1];
    clickDesc.ColSpan=[1,1];

    useTextClickFcn.Type='checkbox';
    useTextClickFcn.Name=DAStudio.message('Simulink:dialog:AnnotationUseTextForClickFcnName');
    useTextClickFcn.Tag='useTextAsClickFcn';
    useTextClickFcn.ObjectProperty='UseDisplayTextAsClickCallback';
    useTextClickFcn.MatlabMethod='annotationddg_cb';
    useTextClickFcn.MatlabArgs={'%dialog','doUseTextAsClickFcn'};
    useTextClickFcn.RowSpan=[2,2];
    useTextClickFcn.ColSpan=[1,1];

    clickFcnEdit.Type='editarea';
    clickFcnEdit.Name='';
    clickFcnEdit.Tag='clickFcnEdit';
    clickFcnEdit.ObjectProperty='ClickFcn';
    prevClickFcn=h.ClickFcn;
    clickFcnEdit.UserData=prevClickFcn;
    clickFcnEdit.Enabled=~strcmp(h.UseDisplayTextAsClickCallback,'on');
    clickFcnEdit.RowSpan=[3,3];
    clickFcnEdit.ColSpan=[1,1];

    activeGroup.Type='group';
    activeGroup.Name=DAStudio.message('Simulink:dialog:AnnotationActiveGroupName');
    activeGroup.ToolTip=DAStudio.message('Simulink:dialog:AnnotationActiveGroupToolTip');
    activeGroup.Tag='ActiveGroup';
    activeGroup.Flat=false;
    activeGroup.Items={clickDesc,useTextClickFcn,clickFcnEdit};
    activeGroup.LayoutGrid=[3,1];
    activeGroup.RowSpan=[2,2];
    activeGroup.ColSpan=[1,1];




    clickFcnTab.Name=DAStudio.message('Simulink:dialog:AnnotationClickFcnTabName');
    clickFcnTab.Items={textGroup,activeGroup};
    clickFcnTab.LayoutGrid=[2,1];
    clickFcnTab.RowStretch=[0,1];
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
