function dlgstruct=getSectionDialogSchema(hView,Data,name)



    tagprefix='TargetPrefSection_';

    compSectionNames=Data.getMemCompilerSectionNames();
    supportAttrCommands=hView.mController.isSectionAttrCommandsSupported();

    CompilerPlacementStack.Type='widgetstack';
    CompilerPlacementStack.Tag=[tagprefix,'CompilerPlacementStack'];
    CompilerPlacementStack.ActiveWidget=0;
    CompilerPlacementStack.Items=cell(1,length(compSectionNames));
    CompilerPlacementStack.RowSpan=[1,8];
    CompilerPlacementStack.ColSpan=[4,6];
    for i=1:length(compSectionNames)
        Placement.Name=hView.mLabels.Section.Placement;
        Placement.Type='listbox';
        Placement.Source=hView;
        Placement.Entries=Data.getMemoryBankNamesForSection(i);



        Placement.Value=hView.getMatchIdx(Placement.Entries,Data.getMemCompilerSectionPlacement(i));
        Placement.Tag=sprintf('%sCompilerPlacementPlac%d',tagprefix,i-1);
        Placement.ListenToProperties={'mCustomMemBanks'};
        Placement.RowSpan=[1,6];
        Placement.ColSpan=[1,4];
        Placement.MultiSelect=hView.mController.canCompilerSectionHaveMultiPlacement(compSectionNames{i});
        Placement.ToolTip=sprintf(hView.mToolTips.Section.Placement,...
        compSectionNames{i},Data.getMemCompilerSectionDescription(i));
        Placement=hView.addControllerCallBack(Placement,'setSectionPlacement','%value',i,compSectionNames{i});

        AttributesLabel.Name=hView.mLabels.Section.Attributes;
        AttributesLabel.Type='text';
        AttributesLabel.RowSpan=[7,7];
        AttributesLabel.ColSpan=[1,1];
        AttributesLabel.Visible=supportAttrCommands;

        Attributes.Type='edit';
        Attributes.Source=hView;
        Attributes.Value=char(Data.getMemCompilerSectionAttributes(i));
        Attributes.Enabled=true;
        Attributes.Tag=sprintf('%sCompilerPlacementAttr%d',tagprefix,i-1);
        Attributes.RowSpan=[7,7];
        Attributes.ColSpan=[2,4];
        Attributes.Visible=supportAttrCommands;
        Attributes=hView.addControllerCallBack(Attributes,'setSectionAttributes','%value',i,compSectionNames{i});

        CommandsLabel.Name=hView.mLabels.Section.Commands;
        CommandsLabel.Type='text';
        CommandsLabel.RowSpan=[8,8];
        CommandsLabel.ColSpan=[1,1];
        CommandsLabel.Visible=supportAttrCommands;

        Commands.Type='edit';
        Commands.Source=hView;
        Commands.Value=char(Data.getMemCompilerSectionCommands(i));
        Commands.Enabled=true;
        Commands.Tag=sprintf('%sCompilerPlacementCmd%d',tagprefix,i-1);
        Commands.RowSpan=[8,8];
        Commands.ColSpan=[2,4];
        Commands.Visible=supportAttrCommands;
        Commands=hView.addControllerCallBack(Commands,'setSectionCommands','%value',i,compSectionNames{i});

        CompilerPlacement.Type='panel';
        CompilerPlacement.Tag=sprintf('%sCompilerPlacement%d',tagprefix,i-1);
        CompilerPlacement.Items={AttributesLabel,Attributes,CommandsLabel,Commands,Placement};
        CompilerPlacement.LayoutGrid=[8,4];
        CompilerPlacement.RowStretch=[0,0,0,0,0,1,0,0];
        CompilerPlacement.ColStretch=[0,0,1];
        CompilerPlacementStack.Items{i}=CompilerPlacement;
    end


    CompilerSectionMap.Name=hView.mLabels.Section.Sections;
    CompilerSectionMap.Type='tree';
    CompilerSectionMap.TreeItems=compSectionNames;
    CompilerSectionMap.TreeItemIds=num2cell(0:length(CompilerSectionMap.TreeItems)-1);
    CompilerSectionMap.Tag=[tagprefix,'CompilerSectionMap'];
    CompilerSectionMap.TargetWidget=[tagprefix,'CompilerPlacementStack'];
    if(~isempty(compSectionNames))
        CompilerSectionMap.Value=CompilerSectionMap.TreeItems{1};
    end
    CompilerSectionMap.RowSpan=[1,8];
    CompilerSectionMap.ColSpan=[1,3];
    CompilerSectionMap.Graphical=true;
    CompilerSectionMap.MinimumSize=[128,128];

    CompilerSection.Name=hView.mLabels.Section.CompilerSections;
    CompilerSection.Type='group';
    CompilerSection.Items={CompilerSectionMap,CompilerPlacementStack};
    CompilerSection.LayoutGrid=[2,6];
    CompilerSection.ColStretch=[0,0,0,0,0,1];
    CompilerSection.RowSpan=[1,1];
    CompilerSection.ColSpan=[1,1];

    cusSectionNames=Data.getMemCustomSectionNames();
    CustomPlacementStack.Type='widgetstack';
    CustomPlacementStack.Tag=[tagprefix,'CustomPlacementStack'];
    CustomPlacementStack.ActiveWidget=0;
    CustomPlacementStack.Items=cell(1,length(cusSectionNames));
    CustomPlacementStack.RowSpan=[1,11];
    CustomPlacementStack.ColSpan=[4,6];
    if(length(cusSectionNames)<1)
        CustomPlacement.Type='panel';
        CustomPlacement.Tag=sprintf('%sCustomPlacementEmpty',tagprefix);
        CustomPlacement.Items={};
        CustomPlacement.LayoutGrid=[9,4];
        CustomPlacementStack.Items={CustomPlacement};
    else
        for i=1:length(cusSectionNames)
            Placement.Name=hView.mLabels.Section.Placement;
            Placement.Type='listbox';
            Placement.Source=hView;
            Placement.Entries=Data.getMemoryBankNamesForCustomSection(i);
            Placement.Value=hView.getMatchIdx(Placement.Entries,Data.getMemCustomSectionPlacement(i));
            Placement.ToolTip=hView.mToolTips.Section.PlacementCustom;
            Placement.Tag=sprintf('%sCustomPlacementPlac%d',tagprefix,i-1);
            Placement.ListenToProperties={'mCustomMemBanks'};
            Placement.MultiSelect=hView.mController.canCompilerSectionHaveMultiPlacement(cusSectionNames{i});
            Placement.RowSpan=[1,4];
            Placement.ColSpan=[1,4];
            Placement.MinimumSize=[200,100];
            Placement=hView.addControllerCallBack(Placement,'setCustomSectionPlacement','%value',i);

            SectionLabel.Name=hView.mLabels.Section.SectionName;
            SectionLabel.Type='text';
            SectionLabel.RowSpan=[5,5];
            SectionLabel.ColSpan=[1,1];
            SectionLabel.Buddy=sprintf('%sCustomPlacementName%d',tagprefix,i-1);

            Section.Type='edit';
            Section.Source=hView;
            Section.Value=cusSectionNames{i};
            Section.Tag=sprintf('%sCustomPlacementName%d',tagprefix,i-1);
            Section.RowSpan=[5,5];
            Section.ColSpan=[2,4];
            Section.DialogRefresh=true;
            Section=hView.addControllerCallBack(Section,'setCustomSectionName','%value',i);

            SectionContentsLabel.Name=hView.mLabels.Section.Contents;
            SectionContentsLabel.Type='text';
            SectionContentsLabel.RowSpan=[6,6];
            SectionContentsLabel.ColSpan=[1,1];
            SectionContentsLabel.Buddy=sprintf('%sCustomPlacementContent%d',tagprefix,i-1);

            SectionContents.Type='combobox';
            SectionContents.Source=hView;
            SectionContents.Entries=Data.getCustomSectionContentsChoices();
            SectionContents.Value=Data.getMemCustomSectionContents(i);
            SectionContents.Tag=sprintf('%sCustomPlacementContent%d',tagprefix,i-1);
            SectionContents.RowSpan=[6,6];
            SectionContents.ColSpan=[2,4];
            SectionContents=hView.addControllerCallBack(SectionContents,'setCustomSectionContent','%value',i);

            AttributesLabel.Name=hView.mLabels.Section.Attributes;
            AttributesLabel.Type='text';
            AttributesLabel.RowSpan=[7,7];
            AttributesLabel.ColSpan=[1,1];
            AttributesLabel.Visible=supportAttrCommands;

            Attributes.Type='edit';
            Attributes.Source=hView;
            Attributes.Value=Data.getMemCustomSectionAttributes(i);
            Attributes.Tag=sprintf('%sCustomPlacementAttr%d',tagprefix,i-1);
            Attributes.RowSpan=[7,7];
            Attributes.ColSpan=[2,4];
            Attributes.Visible=supportAttrCommands;
            Attributes=hView.addControllerCallBack(Attributes,'setCustomSectionAttributes','%value',i);

            CommandsLabel.Name=hView.mLabels.Section.Commands;
            CommandsLabel.Type='text';
            CommandsLabel.RowSpan=[8,8];
            CommandsLabel.ColSpan=[1,1];
            CommandsLabel.Visible=supportAttrCommands;
            CommandsLabel.Buddy=sprintf('%sCustomPlacementCmd%d',tagprefix,i-1);

            Commands.Type='edit';
            Commands.Source=hView;
            Commands.Value=Data.getMemCustomSectionCommands(i);
            Commands.Tag=sprintf('%sCustomPlacementCmd%d',tagprefix,i-1);
            Commands.RowSpan=[8,8];
            Commands.ColSpan=[2,4];
            Commands.Visible=supportAttrCommands;
            Commands=hView.addControllerCallBack(Commands,'setCustomSectionCommands','%value',i);

            CustomPlacement.Type='panel';
            CustomPlacement.Tag=sprintf('%sCustomPlacement%d',tagprefix,i-1);
            CustomPlacement.Items={SectionLabel,Section,...
            SectionContentsLabel,SectionContents,...
            AttributesLabel,Attributes,...
            CommandsLabel,Commands,Placement};
            CustomPlacement.LayoutGrid=[9,4];
            CustomPlacementStack.Items{i}=CustomPlacement;
        end
    end

    CustomSectionMap.Name=hView.mLabels.Section.Sections;
    CustomSectionMap.Type='tree';
    CustomSectionMap.TreeItems=cusSectionNames;
    CustomSectionMap.TreeItemIds=num2cell(0:length(CustomSectionMap.TreeItems)-1);
    CustomSectionMap.Tag=[tagprefix,'CustomSectionMap'];
    CustomSectionMap.TargetWidget=[tagprefix,'CustomPlacementStack'];
    if(~isempty(cusSectionNames))
        CustomSectionMap.Value=CustomSectionMap.TreeItems{1};
    end
    CustomSectionMap.RowSpan=[1,6];
    CustomSectionMap.ColSpan=[1,3];
    CustomSectionMap.Graphical=true;
    CustomSectionMap.MinimumSize=[128,128];

    CustomSectionAdd.Name=hView.mLabels.Section.AddSection;
    CustomSectionAdd.Type='pushbutton';
    CustomSectionAdd.Tag=[tagprefix,'CustomSectionAdd'];
    CustomSectionAdd.RowSpan=[7,7];
    CustomSectionAdd.ColSpan=[1,1];
    CustomSectionAdd.DialogRefresh=true;
    CustomSectionAdd=hView.addControllerCallBack(CustomSectionAdd,'addCustomSection',CustomSectionMap.Tag);

    CustomSectionDel.Name=hView.mLabels.Section.DeleteSection;
    CustomSectionDel.Type='pushbutton';
    CustomSectionDel.Tag=[tagprefix,'CustomSectionDel'];
    CustomSectionDel.RowSpan=[8,8];
    CustomSectionDel.ColSpan=[1,1];
    CustomSectionDel.Enabled=hView.mController.isDeleteCustomSectionEnabled();
    CustomSectionDel.DialogRefresh=true;
    CustomSectionDel=hView.addControllerCallBack(CustomSectionDel,'deleteCustomSection',CustomSectionMap.Tag);

    CustomSection.Name=hView.mLabels.Section.CustomSections;
    CustomSection.Type='group';
    CustomSection.Items={CustomSectionMap,CustomSectionAdd,CustomSectionDel,CustomPlacementStack};
    CustomSection.LayoutGrid=[7,6];
    CustomSection.ColStretch=[0,0,0,0,0,1];
    CustomSection.RowSpan=[2,3];
    CustomSection.ColSpan=[1,1];

    SectionSchemaItems.Type='panel';
    SectionSchemaItems.Tag=[tagprefix,'panel'];
    SectionSchemaItems.Items={CompilerSection,CustomSection};
    SectionSchemaItems.LayoutGrid=[3,9];

    dlgstruct.Name=hView.mLabels.Section.Name;
    dlgstruct.Items={SectionSchemaItems};


