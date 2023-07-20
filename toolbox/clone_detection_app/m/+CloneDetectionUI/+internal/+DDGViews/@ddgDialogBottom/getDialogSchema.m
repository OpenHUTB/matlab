function dlgStruct=getDialogSchema(this)




    cloneUIObj=this.cloneUIObj;
    libFilePath=cloneUIObj.refactoredClonesLibFileName;






    if cloneUIObj.isAcrossModel
        status=cloneUIObj.cloneDetectionStatus;
    else
        status=cloneUIObj.refactorButtonEnable;
    end


    resultMessage=this.result;
    if strcmp(this.status,'success')
        if this.cloneUIObj.compareModelButtonEnable

            resultMessage=[this.result,' '...
            ,DAStudio.message('sl_pir_cpp:creator:ExploreCloneResults',...
            char(this.cloneUIObj.historyVersions(length(this.cloneUIObj.historyVersions))),...
            DAStudio.message('sl_pir_cpp:creator:LogsTabName'))];
        elseif this.cloneUIObj.cloneDetectionStatus&&this.cloneUIObj.refactorButtonEnable

            resultMessage=[this.result,' '...
            ,DAStudio.message('sl_pir_cpp:creator:ExploreResultsTable'),' '...
            ,DAStudio.message('sl_pir_cpp:creator:ExploreCloneResults',...
            char(this.cloneUIObj.historyVersions(length(this.cloneUIObj.historyVersions))),...
            DAStudio.message('sl_pir_cpp:creator:LogsTabName'))];
        end
    end


    ssSourceCloneGroups=...
    CloneDetectionUI.internal.SpreadSheetSource.CloneGroups(cloneUIObj.ddgRight,...
    libFilePath,cloneUIObj.m2mObj,status,...
    cloneUIObj.cloneGroupSidListMap);


    ssSourceModelHierarchy=...
    CloneDetectionUI.internal.SpreadSheetSource.HierarchicalView...
    (this.model,cloneUIObj.m2mObj,cloneUIObj.blockPathCategoryMap,...
    cloneUIObj.cloneDetectionStatus,cloneUIObj.colorCodes);


    ssSourceLogs=...
    CloneDetectionUI.internal.SpreadSheetSource.Logs(this,cloneUIObj.historyVersions);


    ssWidgetCloneGroups.Name='spreadsheet widget list';
    ssWidgetCloneGroups.Type='spreadsheet';
    ssWidgetCloneGroups.Tag='spreadsheetWidgetList';
    ssWidgetCloneGroups.Columns=...
    {DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn1'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn2'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn9'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn3'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn4'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn5'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn6'),...
    DAStudio.message('sl_pir_cpp:creator:cloneGroupsSSColumn8')};
    ssWidgetCloneGroups.Source=ssSourceCloneGroups;
    ssWidgetCloneGroups.Hierarchical=true;
    ssWidgetCloneGroups.RowSpan=[4,5];
    ssWidgetCloneGroups.ColSpan=[1,4];
    ssWidgetCloneGroups.Alignment=0;
    ssWidgetCloneGroups.DialogRefresh=1;
    ssWidgetCloneGroups.SelectionChangedCallback=@(tag,sels,dlg)CloneDetectionUI.internal.SpreadSheetItem.CloneGroups.selectCloneRowCallback(tag,sels,dlg);


    ssWidgetModelHierarchy.Name='spreadsheet widget tree';
    ssWidgetModelHierarchy.Type='spreadsheet';
    ssWidgetModelHierarchy.Tag='modelHierarchySpreadSheetTag';
    ssWidgetModelHierarchy.Columns=...
    {DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn1'),...
    DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn2')};
    ssWidgetModelHierarchy.Source=ssSourceModelHierarchy;
    ssWidgetModelHierarchy.Hierarchical=true;
    ssWidgetModelHierarchy.DialogRefresh=1;


    ssWidgetLogs.Name='spreadsheet widget Logs';
    ssWidgetLogs.Type='spreadsheet';
    ssWidgetLogs.Tag='LogsSpreadSheetTag';
    ssWidgetLogs.Columns={DAStudio.message('sl_pir_cpp:creator:logsSSColumn1')};
    ssWidgetLogs.DialogRefresh=1;
    ssWidgetLogs.Source=ssSourceLogs;


    highlightAllClonesButton.Type='pushbutton';
    highlightAllClonesButton.Name=DAStudio.message('sl_pir_cpp:creator:HighlightAllClones');
    highlightAllClonesButton.RowSpan=[1,1];
    highlightAllClonesButton.ColSpan=[1,2];
    highlightAllClonesButton.Tag='highlight_pushbuttonTag';
    highlightAllClonesButton.WidgetId='highlight_pushbuttonWidgetId';
    highlightAllClonesButton.ObjectMethod='highlightAllClones';
    highlightAllClonesButton.DialogRefresh=true;
    highlightAllClonesButton.Enabled=cloneUIObj.cloneDetectionStatus;

    statusMessage.Type='text';
    statusMessage.Tag='status_message';
    statusMessage.Name=resultMessage;
    statusMessage.RowSpan=[2,2];
    statusMessage.ColSpan=[1,4];
    statusMessage.ForegroundColor=[0,0,160];
    statusMessage.FontPointSize=10;

    extraSectionPanel.Type='panel';
    extraSectionPanel.Name='extraSectionPanel';
    extraSectionPanel.RowSpan=[3,3];
    extraSectionPanel.ColSpan=[1,4];
    extraSectionPanel.Alignment=0;
    extraSectionPanel.LayoutGrid=[2,4];
    extraSectionPanel.ColStretch=[0,0,1,1];
    extraSectionPanel.Items={highlightAllClonesButton,statusMessage};


    libraryNameTextBox.Name=DAStudio.message('sl_pir_cpp:creator:refactorLibNameLabel');
    libraryNameTextBox.Type='edit';
    libraryNameTextBox.Tag='libraryNameTag';
    libraryNameTextBox.WidgetId='libraryNameTextBoxWidgetId';
    libraryNameTextBox.RowSpan=[1,1];
    libraryNameTextBox.ColSpan=[1,2];
    libraryNameTextBox.Value=cloneUIObj.refactoredClonesLibFileName;
    libraryNameTextBox.ObjectMethod='updateRefactorLibFileName';
    libraryNameTextBox.DialogRefresh=true;


    browsebutton.Type='pushbutton';
    browsebutton.Name=DAStudio.message('sl_pir_cpp:creator:browseBtnName');
    browsebutton.RowSpan=[1,1];
    browsebutton.ColSpan=[3,3];
    browsebutton.Tag='browse_pushbuttonTag';
    browsebutton.WidgetId='browse_pushbuttonWidgetId';
    browsebutton.ObjectMethod='browseNewLibFile';
    browsebutton.DialogRefresh=true;

    libraryFileLabel.Type='text';
    libraryFileLabel.Tag='libraryFileLabelTag';
    libraryFileLabel.Name=DAStudio.message('sl_pir_cpp:creator:libraryFileLabel');
    libraryFileLabel.RowSpan=[2,2];
    libraryFileLabel.ColSpan=[1,1];

    spacerWidget2.Type='panel';
    spacerWidget2.RowSpan=[1,1];
    spacerWidget2.ColSpan=[4,4];

    minDiffLabel.Type='text';
    minDiffLabel.Tag='minDiffLabelTag';
    minDiffLabel.Name=DAStudio.message('sl_pir_cpp:creator:minDiffLabelName');
    minDiffLabel.RowSpan=[1,1];
    minDiffLabel.ColSpan=[1,1];

    maxDiffLabel.Type='text';
    maxDiffLabel.Tag='maxDiffLabelTag';
    maxDiffLabel.Name=DAStudio.message('sl_pir_cpp:creator:maxDiffLabelName');
    maxDiffLabel.RowSpan=[1,1];
    maxDiffLabel.ColSpan=[3,3];

    colorMapWidget.Type='image';
    colorMapWidget.FilePath=fullfile(matlabroot,'toolbox',...
    'clone_detection_app','m','ui','images','colormap.png');
    colorMapWidget.ColSpan=[2,2];
    colorMapWidget.RowSpan=[1,1];



    colorMapPanel.Type='panel';
    colorMapPanel.Name='ColorMap';
    colorMapPanel.LayoutGrid=[1,4];
    colorMapPanel.RowSpan=[2,2];
    colorMapPanel.ColSpan=[1,4];
    colorMapPanel.Alignment=0;
    colorMapPanel.ColStretch=[0,0,0,1];
    colorMapPanel.Items={colorMapWidget,minDiffLabel,maxDiffLabel,spacerWidget2};

    newLibUploadPanel.Type='panel';
    newLibUploadPanel.Name='Controls';
    newLibUploadPanel.RowSpan=[1,1];
    newLibUploadPanel.ColSpan=[1,4];
    newLibUploadPanel.Alignment=0;
    newLibUploadPanel.LayoutGrid=[2,4];
    newLibUploadPanel.ColStretch=[0,0,0,1];
    newLibUploadPanel.Items={libraryNameTextBox,browsebutton,libraryFileLabel,spacerWidget2};











    if~this.cloneUIObj.isReplaceExactCloneWithSubsysRef
        cloneGroupsTab.Items={newLibUploadPanel,colorMapPanel,extraSectionPanel,ssWidgetCloneGroups};
    else
        cloneGroupsTab.Items={extraSectionPanel,ssWidgetCloneGroups};
    end
    cloneGroupsTab.Name=DAStudio.message('sl_pir_cpp:creator:cloneGroupsTabName');

    cloneGroupsTab.Tag='clonegroupTag';
    cloneGroupsTab.RowStretch=[0,0,0,1,1];
    cloneGroupsTab.ColStretch=[1,1,1,1];
    cloneGroupsTab.LayoutGrid=[5,4];

    modelHierarchyTab.Name=DAStudio.message('sl_pir_cpp:creator:modelHeirarchyTabName');
    modelHierarchyTab.Items={ssWidgetModelHierarchy};
    modelHierarchyTab.Tag='modelhierarchyTag';

    logsTab.Name=DAStudio.message('sl_pir_cpp:creator:LogsTabName');
    logsTab.Items={ssWidgetLogs};
    logsTab.Tag='logsTag';


    tabcont.Name='tabContainer';
    tabcont.Type='tab';
    tabcont.Tabs={cloneGroupsTab,logsTab,modelHierarchyTab};
    tabcont.Tag='parentContainerTab';
    tabcont.ActiveTab=0;

    tabsPanel=struct('Type','panel','RowSpan',[2,2],'ColSpan',[1,7],...
    'LayoutGrid',[1,1],'ColStretch',0,'ContentsMargins',0);
    tabsPanel.Items={tabcont};

    dlgStruct.DialogTitle='';
    dlgStruct.Items={tabsPanel};
    dlgStruct.DialogMode='Slim';
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.LayoutGrid=[2,7];


