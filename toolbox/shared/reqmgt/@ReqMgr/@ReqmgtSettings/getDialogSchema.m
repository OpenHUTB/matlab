function dlgstruct=getDialogSchema(h,name)%#ok<INUSD>



    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels.dialogName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:SettingsDialogTitle'));
        staticLabels.commonInfoText=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ChangesHaveImmediateEffect'));
    end


    [installed,licensed]=rmi.isInstalled();
    rmiAvailable=installed&&licensed;

    storageTab=makeStorageOptionsTab(rmiAvailable);
    selectionLinkingTab=makeSelectionLinkingTab(rmiAvailable);
    filtersTab=makeFiltersTab(rmiAvailable);
    reportOptionsTab=makeReportOptionsTab(rmiAvailable);

    tabs.Name='settingsTabs';
    tabs.Tag='settingsTabs';
    tabs.Type='tab';

    userTab=rmi.settings_mgr('get','settingsTab');
    if reqmgt('rmiFeature','Experimental')
        coverageTab=rmisl.covFilterDlgTab(rmiAvailable);
        tabs.LayoutGrid=[1,5];
        tabs.Tabs={storageTab,selectionLinkingTab,filtersTab,reportOptionsTab,coverageTab};
        userTab=min(userTab,3+coverageTab.Enabled);
    else
        tabs.LayoutGrid=[1,4];
        tabs.Tabs={storageTab,selectionLinkingTab,filtersTab,reportOptionsTab};
        userTab=min(userTab,length(tabs.Tabs)-1);
    end
    tabs.RowSpan=[1,1];
    tabs.ColSpan=[1,5];

    slIsLoaded=dig.isProductInstalled('Simulink')&&is_simulink_loaded();

    if userTab==0&&~slIsLoaded


        tabs.ActiveTab=2-rmiAvailable;
    elseif~rmiAvailable

        tabs.ActiveTab=2-2*slIsLoaded;
    else

        tabs.ActiveTab=userTab;
    end
    tabs.TabChangedCallback='ReqMgr.settings_switchtabs';



    commonInfoText.Type='text';
    commonInfoText.Name=staticLabels.commonInfoText;
    commonInfoText.RowSpan=[2,2];
    commonInfoText.ColSpan=[1,3];
    commonInfoText.Alignment=6;


    dlgstruct.StandaloneButtonSet={''};

    helpButton.Type='pushbutton';
    helpButton.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Help'));
    helpButton.RowSpan=[2,2];
    helpButton.ColSpan=[4,4];
    helpButton.Tag='helpButton';
    helpButton.Alignment=10;
    helpButton.MatlabMethod='feval';
    helpButton.MatlabArgs={@showHelp};

    closeButton.Type='pushbutton';
    closeButton.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Close'));
    closeButton.RowSpan=[2,2];
    closeButton.ColSpan=[5,5];
    closeButton.Tag='closeButton';
    closeButton.Alignment=10;
    closeButton.MatlabMethod='feval';
    closeButton.MatlabArgs={@close_this,'%dialog'};


    dlgstruct.DialogTitle=staticLabels.dialogName;
    dlgstruct.DialogTag='RequirementSettings';
    dlgstruct.LayoutGrid=[2,5];
    dlgstruct.Items={tabs,commonInfoText,helpButton,closeButton};
    dlgstruct.CloseCallback='rmi_settings_dlg';
    dlgstruct.CloseArgs={'clear'};
end

function close_this(dialogH)
    dialogH.delete;

end

function showHelp()
    docMap=[docroot,'/slrequirements/helptargets.map'];
    currentTab=rmi.settings_mgr('get','settingsTab');
    switch currentTab
    case 0
        docId='modelrequirements_storage';
    case 1
        docId='modelrequirements_linking';
    case 2
        docId='modelrequirements_filtering';
    case 3
        docId='modelrequirements_report';
    otherwise
        docId='modelrequirements_toc';
    end
    feval('helpview',docMap,docId);
end



function reportOptionsTab=makeReportOptionsTab(licensed)

    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels=reportOptionsLabels();
    end

    reportSettings=rmi.settings_mgr('get','reportSettings');
    if~isfield(reportSettings,'followLibraryLinks')

        reportSettings.followLibraryLinks=false;
    end

    reportHighlightCheck.Type='checkbox';
    reportHighlightCheck.Name=staticLabels.reportHighlightCheck;
    reportHighlightCheck.Tag='highlightCheck';
    reportHighlightCheck.RowSpan=[1,1];
    reportHighlightCheck.ColSpan=[1,1];
    reportHighlightCheck.Value=0+reportSettings.highlightModel;
    reportHighlightCheck.MatlabMethod='feval';
    reportHighlightCheck.MatlabArgs={@report_setting_changed,'%source','%dialog'};

    reportLibrariesCheck.Type='checkbox';
    reportLibrariesCheck.Name=staticLabels.reportLibrariesCheck;
    reportLibrariesCheck.Tag='libsCheck';
    reportLibrariesCheck.RowSpan=[2,2];
    reportLibrariesCheck.ColSpan=[1,1];
    reportLibrariesCheck.Value=0+reportSettings.followLibraryLinks;
    reportLibrariesCheck.MatlabMethod='feval';
    reportLibrariesCheck.MatlabArgs={@report_setting_changed,'%source','%dialog'};

    reportMissingReqsCheck.Type='checkbox';
    reportMissingReqsCheck.Name=staticLabels.reportMissingReqsCheck;
    reportMissingReqsCheck.Tag='missingReqsCheck';
    reportMissingReqsCheck.RowSpan=[3,3];
    reportMissingReqsCheck.ColSpan=[1,1];
    reportMissingReqsCheck.Value=0+reportSettings.includeMissingReqs;
    reportMissingReqsCheck.MatlabMethod='feval';
    reportMissingReqsCheck.MatlabArgs={@report_setting_changed,'%source','%dialog'};

    reportUserTagsCheck.Type='checkbox';
    reportUserTagsCheck.Name=staticLabels.reportUserTagsCheck;
    reportUserTagsCheck.Tag='userTagsCheck';
    reportUserTagsCheck.RowSpan=[4,4];
    reportUserTagsCheck.ColSpan=[1,1];
    reportUserTagsCheck.Value=0+reportSettings.includeTags;
    reportUserTagsCheck.MatlabMethod='feval';
    reportUserTagsCheck.MatlabArgs={@report_setting_changed,'%source','%dialog'};

    reportDocIndexCheck.Type='checkbox';
    reportDocIndexCheck.Name=staticLabels.reportDocIndexCheck;
    reportDocIndexCheck.Tag='docIndexCheck';
    reportDocIndexCheck.RowSpan=[5,5];
    reportDocIndexCheck.ColSpan=[1,1];
    reportDocIndexCheck.Value=0+reportSettings.useDocIndex;
    reportDocIndexCheck.MatlabMethod='feval';
    reportDocIndexCheck.MatlabArgs={@report_setting_changed,'%source','%dialog'};

    reportDetailsCheck.Type='checkbox';
    reportDetailsCheck.Name=staticLabels.reportDetailsCheck;
    reportDetailsCheck.Tag='reportDetailsCheck';
    reportDetailsCheck.RowSpan=[6,6];
    reportDetailsCheck.ColSpan=[1,1];
    reportDetailsCheck.Value=0+reportSettings.detailsLevel;
    reportDetailsCheck.MatlabMethod='feval';
    reportDetailsCheck.MatlabArgs={@details_level_changed,'%source','%dialog'};

    reportLinksToObjectsCheck.Type='checkbox';
    reportLinksToObjectsCheck.Name=staticLabels.reportLinksToObjects;
    reportLinksToObjectsCheck.Tag='linksToObjectsCheck';
    reportLinksToObjectsCheck.RowSpan=[1,1];
    reportLinksToObjectsCheck.ColSpan=[1,1];
    reportLinksToObjectsCheck.Value=0+reportSettings.linksToObjects;
    reportLinksToObjectsCheck.MatlabMethod='feval';
    reportLinksToObjectsCheck.MatlabArgs={@nav_setting_changed,'%dialog'};

    reportLinksUseMatlabCheck.Type='checkbox';
    reportLinksUseMatlabCheck.Name=staticLabels.reportNavUseMatlab;
    reportLinksUseMatlabCheck.Tag='linksToDocsCheck';
    reportLinksUseMatlabCheck.RowSpan=[2,2];
    reportLinksUseMatlabCheck.ColSpan=[1,1];
    reportLinksUseMatlabCheck.Value=0+reportSettings.navUseMatlab;
    reportLinksUseMatlabCheck.MatlabMethod='feval';
    reportLinksUseMatlabCheck.MatlabArgs={@nav_setting_changed,'%dialog'};

    reportGroup.Type='group';
    reportGroup.Name=staticLabels.reportTabGroup;
    reportGroup.LayoutGrid=[6,1];
    reportGroup.Items={...
    reportHighlightCheck,...
    reportLibrariesCheck,...
    reportMissingReqsCheck,...
    reportUserTagsCheck,...
    reportDocIndexCheck,...
    reportDetailsCheck};
    reportGroup.Tag='reportGroup';

    reportNavGroup.Type='group';
    reportNavGroup.Name=staticLabels.reportNavGroup;
    reportNavGroup.LayoutGrid=[2,1];
    reportNavGroup.Items={...
    reportLinksToObjectsCheck,...
    reportLinksUseMatlabCheck};
    reportNavGroup.Tag='reportNavGroup';

    emptySpace.Type='text';
    emptySpace.Name=' ';

    reportOptionsTab.Name=staticLabels.reportTabName;
    reportOptionsTab.Tag='reportTab';
    reportOptionsTab.Items={emptySpace,reportGroup,emptySpace,reportNavGroup,emptySpace};
    reportOptionsTab.Enabled=0+licensed;



    function out=reportOptionsLabels()
        out.reportTabName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Report'));
        out.reportTabGroup=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:CustomizeReportWithoutReportgen'));
        out.reportHighlightCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:HighlightBeforeReport'));
        out.reportLibrariesCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:IncludeLinksInLibraries'));
        out.reportUserTagsCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ShowUserTags'));
        out.reportDocIndexCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseDocumentIDs'));
        out.reportLinksToObjects=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:IncludeLinksToObjects'));
        out.reportMissingReqsCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ReportNoLinks'));
        out.reportDetailsCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:IncludeDetails'));
        out.reportNavGroup=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:NavReportToDoc'));
        out.reportNavUseMatlab=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:NavReportUseMatlab'));
        out.reportNavUseDoc=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:NavReportUseDoc'));
    end

    function details_level_changed(h,dialogH)%#ok<INUSL>

        reportSettings=rmi.settings_mgr('get','reportSettings');
        newValue=dialogH.getWidgetValue('reportDetailsCheck');
        if logical(newValue)~=reportSettings.detailsLevel
            reportSettings.detailsLevel=logical(newValue);
            rmi.settings_mgr('set','reportSettings',reportSettings);
        end

        dialogH.apply();
    end

    function report_setting_changed(h,dialogH)%#ok<INUSL>

        reportSettings=rmi.settings_mgr('get','reportSettings');


        reportSettings.highlightModel=dialogH.getWidgetValue('highlightCheck');
        reportSettings.followLibraryLinks=dialogH.getWidgetValue('libsCheck');
        reportSettings.includeMissingReqs=dialogH.getWidgetValue('missingReqsCheck');
        reportSettings.useDocIndex=dialogH.getWidgetValue('docIndexCheck');
        reportSettings.includeTags=dialogH.getWidgetValue('userTagsCheck');


        rmi.settings_mgr('set','reportSettings',reportSettings);


        dialogH.apply();
    end

    function nav_setting_changed(dialogH)
        reportSettings=rmi.settings_mgr('get','reportSettings');
        if dialogH.getWidgetValue('linksToDocsCheck')&&~reportSettings.navUseMatlab

            if~rmiut.matlabConnectorOn('force')
                errordlg(...
                getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseMcLinksMessage')),...
                getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseMcLinksTitle')),'model');
                dialogH.setWidgetValue('linksToDocsCheck',false);
                return;
            else
                reportSettings.navUseMatlab=true;
            end
        else
            reportSettings.navUseMatlab=dialogH.getWidgetValue('linksToDocsCheck');
            reportSettings.linksToObjects=dialogH.getWidgetValue('linksToObjectsCheck');
        end
        rmi.settings_mgr('set','reportSettings',reportSettings);
        dialogH.apply();
    end

end

function selectionLinkingTab=makeSelectionLinkingTab(licensed)

    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels=selectionLinkingLabels();
    end

    activeModes=rmi.settings_mgr('get','selectIdx');

    selectionActiveText.Type='text';
    selectionActiveText.Name=staticLabels.selectionActiveText;
    selectionActiveText.RowSpan=[1,1];
    selectionActiveText.ColSpan=[1,2];

    selectionWordCheck.Type='checkbox';
    selectionWordCheck.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Word'));
    selectionWordCheck.Tag='wordCheck';
    selectionWordCheck.RowSpan=[1,1];
    selectionWordCheck.ColSpan=[3,3];
    selectionWordCheck.Value=0+activeModes(1);
    selectionWordCheck.MatlabMethod='feval';
    selectionWordCheck.MatlabArgs={@selection_setting_changed,'%dialog'};
    selectionWordCheck.Enabled=ispc;

    selectionExcelCheck.Type='checkbox';
    selectionExcelCheck.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Excel'));
    selectionExcelCheck.Tag='excelCheck';
    selectionExcelCheck.RowSpan=[1,1];
    selectionExcelCheck.ColSpan=[4,4];
    selectionExcelCheck.Value=0+activeModes(2);
    selectionExcelCheck.MatlabMethod='feval';
    selectionExcelCheck.MatlabArgs={@selection_setting_changed,'%dialog'};
    selectionExcelCheck.Enabled=ispc;

    selectionDoorsCheck.Type='checkbox';
    selectionDoorsCheck.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:DOORS'));
    selectionDoorsCheck.Tag='doorsCheck';
    selectionDoorsCheck.RowSpan=[1,1];
    selectionDoorsCheck.ColSpan=[5,5];
    selectionDoorsCheck.Value=0+activeModes(3);
    selectionDoorsCheck.MatlabMethod='feval';
    selectionDoorsCheck.MatlabArgs={@selection_setting_changed,'%dialog'};
    selectionDoorsCheck.Enabled=...
    (ispc&&rmi.settings_mgr('get','isDoorsSetup'))||...
    (rmi.isInstalled&&~isempty(rmipref('OslcServerAddress')));

    linkSettings=rmi.settings_mgr('get','linkSettings');

    selectionDocPathText.Type='text';
    selectionDocPathText.Name=staticLabels.selectionDocPathText;
    selectionDocPathText.RowSpan=[2,2];
    selectionDocPathText.ColSpan=[1,2];

    selectionDocPathCombo.Type='combobox';
    selectionDocPathCombo.Tag='docPathCombo';
    selectionDocPathCombo.RowSpan=[2,2];
    selectionDocPathCombo.ColSpan=[3,5];
    selectionDocPathCombo.Entries=staticLabels.selectionDocPathOptions;
    selectionDocPathCombo.MatlabMethod='feval';
    selectionDocPathCombo.MatlabArgs={@selection_setting_changed,'%dialog'};
    idx=strcmp(docPathOptions(),linkSettings.docPathStorage);
    selectionDocPathCombo.Value=find(idx>0)-1;

    selectionTagLabel.Name=staticLabels.selectionTagLabel;
    selectionTagLabel.Type='text';
    selectionTagLabel.Tag='selectionTagLabel';
    selectionTagLabel.RowSpan=[3,3];
    selectionTagLabel.ColSpan=[1,2];

    selectionTagEdit.Type='combobox';
    selectionTagEdit.Tag='selectionTagEdit';
    selectionTagEdit.ToolTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:CSVListOfTags'));
    selectionTagEdit.Editable=true;
    selectionTagEdit.Value=rmi.settings_mgr('get','selectTag');
    selectionTagEdit.RowSpan=[3,3];
    selectionTagEdit.ColSpan=[3,5];
    selectionTagEdit.Entries={};
    if(licensed)
        history=rmi.history('tags');
        if~isempty(history)
            selectionTagEdit.Entries=history;
        end
    end
    selectionTagEdit.MatlabMethod='feval';
    selectionTagEdit.MatlabArgs={@selection_setting_changed,'%dialog'};

    selectionGroup1.Type='group';
    selectionGroup1.Name=staticLabels.selectionTabGroup1;
    selectionGroup1.LayoutGrid=[3,5];
    selectionGroup1.Items={...
    selectionActiveText,selectionWordCheck,selectionExcelCheck,selectionDoorsCheck,...
    selectionDocPathText,selectionDocPathCombo,...
    selectionTagLabel,selectionTagEdit};
    selectionGroup1.Tag='selectionGroup1';
    selectionGroup1.Enabled=0+licensed;


    selectionTwoWayCheck.Type='checkbox';
    selectionTwoWayCheck.Name=staticLabels.selectionTwoWayCheck;
    selectionTwoWayCheck.ToolTip=staticLabels.selectionTwoWayTip;
    selectionTwoWayCheck.Tag='twoWayCheck';
    selectionTwoWayCheck.RowSpan=[1,1];
    selectionTwoWayCheck.ColSpan=[1,19];
    selectionTwoWayCheck.Value=0+linkSettings.twoWayLink;
    selectionTwoWayCheck.MatlabMethod='feval';
    selectionTwoWayCheck.MatlabArgs={@twoWay_setting_changed,'%dialog'};

    selectionModelPathCheck.Type='checkbox';
    selectionModelPathCheck.Tag='modelPathCheck';
    selectionModelPathCheck.ToolTip=staticLabels.selectionModelPathTip;
    selectionModelPathCheck.Name=staticLabels.selectionModelPathCheck;
    selectionModelPathCheck.RowSpan=[2,2];
    selectionModelPathCheck.ColSpan=[2,19];
    selectionModelPathCheck.Enabled=selectionTwoWayCheck.Value;
    selectionModelPathCheck.MatlabMethod='feval';
    selectionModelPathCheck.MatlabArgs={@twoWay_setting_changed,'%dialog'};
    selectionModelPathCheck.Value=strcmp(linkSettings.modelPathStorage,'absolute');

    selectionBitmapCheck.Type='checkbox';
    selectionBitmapCheck.Name=staticLabels.selectionBitmapCheck;
    selectionBitmapCheck.ToolTip=staticLabels.selectionBitmapTip;
    selectionBitmapCheck.Tag='bitmapCheck';
    selectionBitmapCheck.RowSpan=[3,3];
    selectionBitmapCheck.ColSpan=[2,19];
    selectionBitmapCheck.Value=0+linkSettings.slrefCustomized;
    selectionBitmapCheck.MatlabMethod='feval';
    selectionBitmapCheck.MatlabArgs={@twoWay_setting_changed,'%dialog'};
    selectionBitmapCheck.Enabled=selectionTwoWayCheck.Value;

    selectionBitmpaPathText.Type='text';
    if isempty(linkSettings.slrefUserBitmap)
        bitmapPath=['      ',getString(message('Slvnv:reqmgt:Settings:getDialogSchema:NoCustomBitmapSelected'))];
    else
        bitmapPath=['      ',linkSettings.slrefUserBitmap];
        maxLength=50;
        if length(bitmapPath)>maxLength
            bitmapPath=['      ...',bitmapPath(end-maxLength+11:end)];
        end
    end
    selectionBitmpaPathText.Name=bitmapPath;
    selectionBitmpaPathText.Tag='bitmapPath';
    selectionBitmpaPathText.RowSpan=[4,4];
    selectionBitmpaPathText.ColSpan=[2,15];
    selectionBitmpaPathText.Enabled=selectionTwoWayCheck.Value&&selectionBitmapCheck.Value;

    selectionBitmapBrowser.Type='pushbutton';
    selectionBitmapBrowser.Name=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Browse'));
    selectionBitmapBrowser.ToolTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:PictureFile'));
    selectionBitmapBrowser.Tag='bitmapBrowser';
    selectionBitmapBrowser.RowSpan=[4,4];
    selectionBitmapBrowser.ColSpan=[16,19];
    selectionBitmapBrowser.MatlabMethod='feval';
    selectionBitmapBrowser.MatlabArgs={@select_bitmap,'%source','%dialog'};
    selectionBitmapBrowser.Enabled=selectionTwoWayCheck.Value&&selectionBitmapCheck.Value;

    selectionActiveXCheck.Type='checkbox';
    selectionActiveXCheck.Tag='useActiveX';
    selectionActiveXCheck.Name=staticLabels.useActiveX;
    selectionActiveXCheck.ToolTip=staticLabels.useActiveXTip;
    selectionActiveXCheck.Value=ispc&&linkSettings.useActiveX;
    selectionActiveXCheck.OrientHorizontal=true;
    selectionActiveXCheck.RowSpan=[5,5];
    selectionActiveXCheck.ColSpan=[2,19];
    selectionActiveXCheck.Enabled=selectionTwoWayCheck.Value;
    selectionActiveXCheck.MatlabMethod='feval';
    selectionActiveXCheck.MatlabArgs={@twoWay_setting_changed,'%dialog'};


    if ispc&&~linkSettings.useActiveX
        if~rmiut.matlabConnectorOn()
            selectionActiveXCheck.Value=true;
            linkSettings.useActiveX=true;
            rmi.settings_mgr('set','linkSettings',linkSettings);
        end
    end

    selectionGroup2.Type='group';
    selectionGroup2.Name=staticLabels.selectionTabGroup2;
    selectionGroup2.LayoutGrid=[5,19];
    selectionGroup2.Items={...
    selectionTwoWayCheck,...
    selectionModelPathCheck,...
    selectionBitmapCheck,...
    selectionBitmpaPathText,selectionBitmapBrowser,...
    selectionActiveXCheck};
    selectionGroup2.Tag='selectionGroup2';
    selectionGroup2.Enabled=0+licensed;
    selectionLinkingTab.Name=staticLabels.selectionTabName;
    selectionLinkingTab.Tag='selectionTab';

    mlConnectorCheck.Type='checkbox';
    mlConnectorCheck.Name=staticLabels.mcCheckboxName;
    mlConnectorCheck.ToolTip=staticLabels.mcCheckboxTooltip;
    mlConnectorCheck.Tag='externalNavigationCheck';
    mlConnectorCheck.MatlabMethod='feval';
    mlConnectorCheck.MatlabArgs={@mlConnector_toggle,'%dialog'};
    try



        currentValue=rmipref('UnsecureHttpRequests');
        mlConnectorCheck.Value=0+currentValue;
    catch
        mlConnectorCheck.Value=false;
        mlConnectorCheck.Enabled=false;
    end

    emptySpace.Type='text';
    emptySpace.Name=' ';

    selectionLinkingTab.Items={emptySpace,selectionGroup1,selectionGroup2,mlConnectorCheck};




    function out=docPathOptions()
        out={'absolute','pwdRelative','modelRelative','none'};
    end

    function mlConnector_toggle(dialogH)
        rmipref('UnsecureHttpRequests',dialogH.getWidgetValue('externalNavigationCheck'));
    end

    function select_bitmap(~,dialogH)

        [fileName,pathName]=uigetfile({'*.bmp','Bitmap files ( *.bmp )';...
        '*.ico','Icon files ( *.ico )'},...
        getString(message('Slvnv:reqmgt:Settings:getDialogSchema:SelectBitmapForButton')));

        if isempty(fileName)||~ischar(fileName)
            return
        else
            settings=rmi.settings_mgr('get','linkSettings');
            settings.slrefUserBitmap=[pathName,fileName];
            rmi.settings_mgr('set','linkSettings',settings);
            dialogH.refresh();
        end
    end

    function selection_setting_changed(dialogH)

        settings=rmi.settings_mgr('get','linkSettings');


        docPathIdx=dialogH.getWidgetValue('docPathCombo');
        docPath=docPathOptions();
        if~strcmp(settings.docPathStorage,docPath{docPathIdx+1})
            settings.docPathStorage=docPath{docPathIdx+1};
            rmi.settings_mgr('set','linkSettings',settings);
        else
            oldIdx=rmi.settings_mgr('get','selectIdx');
            newIdx(1)=dialogH.getWidgetValue('wordCheck');
            newIdx(2)=dialogH.getWidgetValue('excelCheck');
            newIdx(3)=dialogH.getWidgetValue('doorsCheck');
            if any(newIdx~=oldIdx)
                rmi.settings_mgr('set','selectIdx',newIdx);
            else

                currentTag=rmi.settings_mgr('get','selectTag');
                tag=strtrim(dialogH.getWidgetValue('selectionTagEdit'));
                if~strcmp(tag,currentTag)
                    rmi.settings_mgr('set','selectTag',tag);
                else




                end
            end
        end


        dialogH.apply();
    end

    function twoWay_setting_changed(dialogH)

        settings=rmi.settings_mgr('get','linkSettings');

        if settings.twoWayLink~=dialogH.getWidgetValue('twoWayCheck')
            settings.twoWayLink=dialogH.getWidgetValue('twoWayCheck');

            dialogH.setEnabled('modelPathText',settings.twoWayLink);
            dialogH.setEnabled('modelPathCheck',settings.twoWayLink);
            dialogH.setEnabled('bitmapCheck',settings.twoWayLink);
            dialogH.setEnabled('bitmapPath',settings.twoWayLink&&dialogH.getWidgetValue('bitmapCheck'));
            dialogH.setEnabled('bitmapBrowser',settings.twoWayLink&&dialogH.getWidgetValue('bitmapCheck'));
            dialogH.setEnabled('useActiveX',ispc&&settings.twoWayLink);
            if settings.twoWayLink&&dialogH.getWidgetValue('useActiveX')
                rmicom.actxinit();
            end
        else
            if dialogH.getWidgetValue('modelPathCheck')
                modelPathOption='absolute';
            else
                modelPathOption='none';
            end
            if~strcmp(settings.modelPathStorage,modelPathOption)
                settings.modelPathStorage=modelPathOption;
            else
                customBitmap=dialogH.getWidgetValue('bitmapCheck');
                if customBitmap~=settings.slrefCustomized
                    settings.slrefCustomized=dialogH.getWidgetValue('bitmapCheck');
                    dialogH.setEnabled('bitmapPath',settings.twoWayLink&&dialogH.getWidgetValue('bitmapCheck'));
                    dialogH.setEnabled('bitmapBrowser',settings.twoWayLink&&dialogH.getWidgetValue('bitmapCheck'));
                elseif ispc
                    useActiveX=dialogH.getWidgetValue('useActiveX');
                    if useActiveX~=settings.useActiveX
                        if useActiveX


                            rmicom.actxinit();
                        else





                            if~rmiut.matlabConnectorOn('force')
                                dialogH.setWidgetValue('useActiveX',true);
                                errordlg(...
                                getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseActiveXForceMessage')),...
                                getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseActiveXForceTitle')),'model');
                                return;
                            end
                        end
                        settings.useActiveX=useActiveX;
                    end
                end
            end
        end


        rmi.settings_mgr('set','linkSettings',settings);


        dialogH.apply();
    end

    function out=selectionLinkingLabels()

        out.selectionTabName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:SelectionLinking'));
        out.selectionTabGroup1=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:LinkingActiveSelection'));
        out.selectionActiveText=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:EnabledApplications'));
        out.selectionDocPathText=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:DocumentFileReference'));
        out.selectionDocPathOptions={...
        getString(message('Slvnv:reqmgt:Settings:getDialogSchema:AbsolutePath')),...
        getString(message('Slvnv:reqmgt:Settings:getDialogSchema:PathRelativeToCurrentFolder')),...
        getString(message('Slvnv:reqmgt:Settings:getDialogSchema:PathRelativeToModelFolder')),...
        getString(message('Slvnv:reqmgt:Settings:getDialogSchema:FilenameOnly'))};
        out.selectionTabGroup2=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:WhenCreating'));
        out.selectionTwoWayCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ModifyDestination'));
        out.selectionTwoWayTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ModifyDestinationTip'));
        out.selectionModelPathCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:AbsolutePathToModel'));
        out.selectionModelPathTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:AbsolutePathToModelTip'));
        out.selectionBitmapCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:SelectionBitmapCheck'));
        out.selectionBitmapTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:SelectionBitmapTip'));
        out.selectionTagLabel=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ApplyTagToNewLinks'));
        out.useActiveX=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseActiveX'));
        out.useActiveXTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UseActiveXTip'));
        out.mcCheckboxName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:McCheckboxName'));
        out.mcCheckboxTooltip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:McCheckboxTooltip'));
    end

end

function filtersTab=makeFiltersTab(licensed)

    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels=filtersTabLabels();
    end

    filterSettings=rmi.settings_mgr('get','filterSettings');

    filterEnabledCheck.Type='checkbox';
    filterEnabledCheck.Name=staticLabels.filterEnabledCheck;
    filterEnabledCheck.Tag='filterEnabledCheck';
    filterEnabledCheck.ToolTip=staticLabels.filterEnabledCheckTip;
    filterEnabledCheck.RowSpan=[1,1];
    filterEnabledCheck.ColSpan=[1,2];
    filterEnabledCheck.Value=0+filterSettings.enabled;
    filterEnabledCheck.MatlabMethod='feval';
    filterEnabledCheck.MatlabArgs={@filter_changed,'%source','%dialog'};

    filterRequireLabel.Name=staticLabels.filterRequireLabel;
    filterRequireLabel.Type='text';
    filterRequireLabel.Tag='filterRequireLabel';
    filterRequireLabel.Enabled=filterSettings.enabled;
    filterRequireLabel.RowSpan=[2,2];
    filterRequireLabel.ColSpan=[1,1];

    filterRequireEdit.Type='edit';
    filterRequireEdit.Tag='filterRequireEdit';
    filterRequireEdit.Value=rmiut.cellToStr(filterSettings.tagsRequire);
    filterRequireEdit.Enabled=filterSettings.enabled;
    filterRequireEdit.RowSpan=[2,2];
    filterRequireEdit.ColSpan=[2,2];
    filterRequireEdit.MatlabMethod='feval';
    filterRequireEdit.MatlabArgs={@filter_changed,'%source','%dialog'};

    filterExcludeLabel.Name=staticLabels.filterExcludeLabel;
    filterExcludeLabel.Type='text';
    filterExcludeLabel.Tag='filterExcludeLabel';
    filterExcludeLabel.Enabled=filterSettings.enabled;
    filterExcludeLabel.RowSpan=[3,3];
    filterExcludeLabel.ColSpan=[1,1];

    filterExcludeEdit.Type='edit';
    filterExcludeEdit.Tag='filterExcludeEdit';
    filterExcludeEdit.Value=rmiut.cellToStr(filterSettings.tagsExclude);
    filterExcludeEdit.Enabled=filterSettings.enabled;
    filterExcludeEdit.RowSpan=[3,3];
    filterExcludeEdit.ColSpan=[2,2];
    filterExcludeEdit.MatlabMethod='feval';
    filterExcludeEdit.MatlabArgs={@filter_changed,'%source','%dialog'};

    filterMenusCheck.Type='checkbox';
    filterMenusCheck.Name=staticLabels.filterMenusCheck;
    filterMenusCheck.Tag='filterMenusCheck';
    filterMenusCheck.RowSpan=[4,4];
    filterMenusCheck.ColSpan=[2,2];
    filterMenusCheck.Value=0+filterSettings.filterMenus;
    filterMenusCheck.Enabled=filterSettings.enabled;
    filterMenusCheck.MatlabMethod='feval';
    filterMenusCheck.MatlabArgs={@filter_changed,'%source','%dialog'};

    filterConsistencyCheck.Type='checkbox';
    filterConsistencyCheck.Name=staticLabels.filterConsistencyCheck;
    filterConsistencyCheck.Tag='filterConsistencyCheck';
    filterConsistencyCheck.RowSpan=[5,5];
    filterConsistencyCheck.ColSpan=[2,2];
    filterConsistencyCheck.Value=0+filterSettings.filterConsistency;
    filterConsistencyCheck.Enabled=filterSettings.enabled&&licensed;
    filterConsistencyCheck.MatlabMethod='feval';
    filterConsistencyCheck.MatlabArgs={@filter_changed,'%source','%dialog'};


    filterGroup1.Type='group';
    filterGroup1.Name=staticLabels.filterTabGroup1;
    filterGroup1.LayoutGrid=[5,2];
    filterGroup1.Items={...
    filterEnabledCheck,...
    filterRequireLabel,filterRequireEdit,...
    filterExcludeLabel,filterExcludeEdit,...
    filterMenusCheck,...
    filterConsistencyCheck};
    filterGroup1.Tag='filterGroup1';

    filterSurrogateCheck.Type='checkbox';
    filterSurrogateCheck.Name=staticLabels.filterSurrogateCheck;
    filterSurrogateCheck.Tag='filterSurrogateCheck';
    filterSurrogateCheck.ToolTip=staticLabels.filterSurrogateCheckTip;
    filterSurrogateCheck.RowSpan=[1,1];
    filterSurrogateCheck.ColSpan=[1,1];
    filterSurrogateCheck.Value=0+filterSettings.filterSurrogateLinks;
    filterSurrogateCheck.Enabled=0+ispc;
    filterSurrogateCheck.MatlabMethod='feval';
    filterSurrogateCheck.MatlabArgs={@filter_changed,'%source','%dialog'};

    filterGroup2.Type='group';
    filterGroup2.Name=staticLabels.filterTabGroup2;
    filterGroup2.LayoutGrid=[1,1];
    filterGroup2.Items={filterSurrogateCheck};
    filterGroup2.Tag='filterGroup2';

    emptySpace.Type='text';
    emptySpace.Name=' ';

    filtersTab.Name=staticLabels.filterTabName;
    filtersTab.Tag='filterTab';
    filtersTab.Items={emptySpace,filterGroup1,emptySpace,filterGroup2,emptySpace};


    function out=filtersTabLabels()
        out.filterTabName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Filters'));
        out.filterTabGroup1=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:UserTagFilters'));
        out.filterEnabledCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:FilterLinksHighlightingReporting'));
        out.filterEnabledCheckTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:FilterLinksHighlightingReportingTip'));
        out.filterRequireLabel=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:IncludeLinksAnyTags'));
        out.filterExcludeLabel=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ExcludeLinksAnyTags'));
        out.filterMenusCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ApplySameFiltersLabels'));
        out.filterConsistencyCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ApplySameFiltersConsistencyChecking'));
        out.filterTabGroup2=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:LinkTypeFilters'));
        out.filterSurrogateCheck=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:DisableSurrogateItemLinks'));
        out.filterSurrogateCheckTip=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:DisableSurrogateItemLinksTip'));
    end

    function filter_changed(h,dialogH)%#ok<INUSL>

        filterSettings=rmi.settings_mgr('get','filterSettings');


        tagsRequire=rmiut.strToCell(dialogH.getWidgetValue('filterRequireEdit'));
        tagsExclude=rmiut.strToCell(dialogH.getWidgetValue('filterExcludeEdit'));
        nowEnabled=dialogH.getWidgetValue('filterEnabledCheck');





        filter_modified=false;
        if nowEnabled~=filterSettings.enabled||...
            ~all(size(tagsRequire)==size(filterSettings.tagsRequire))||...
            ~all(strcmp(tagsRequire,filterSettings.tagsRequire))||...
            ~all(size(tagsExclude)==size(filterSettings.tagsExclude))||...
            ~all(strcmp(tagsExclude,filterSettings.tagsExclude))
            filter_modified=true;
            filterSettings.tagsRequire=tagsRequire;
            filterSettings.tagsExclude=tagsExclude;
            filterSettings.enabled=nowEnabled;
        end



        newMenusFilter=dialogH.getWidgetValue('filterMenusCheck');
        newSurrogateFilter=dialogH.getWidgetValue('filterSurrogateCheck');
        update_sysreq_blocks=false;
        if newMenusFilter~=filterSettings.filterMenus||...
            newSurrogateFilter~=filterSettings.filterSurrogateLinks||...
            (filter_modified&&filterSettings.filterMenus)
            update_sysreq_blocks=true;
            filterSettings.filterMenus=newMenusFilter;
            filterSettings.filterSurrogateLinks=newSurrogateFilter;
        end


        filterSettings.filterConsistency=dialogH.getWidgetValue('filterConsistencyCheck');


        rmi.settings_mgr('set','filterSettings',filterSettings);


        dialogH.setEnabled('filterRequireLabel',filterSettings.enabled);
        dialogH.setEnabled('filterExcludeLabel',filterSettings.enabled);
        dialogH.setEnabled('filterRequireEdit',filterSettings.enabled);
        dialogH.setEnabled('filterExcludeEdit',filterSettings.enabled);
        dialogH.setEnabled('filterMenusCheck',filterSettings.enabled);
        dialogH.setEnabled('filterConsistencyCheck',filterSettings.enabled&&licensed);


        all_systems=find_system('type','block_diagram');
        filtered_systems=all_systems(~strncmp(all_systems,'simulink',8)&~strcmp(all_systems,'reqmanage'));
        for i=1:length(filtered_systems)
            update_highlighting(filtered_systems{i},false,filter_modified,update_sysreq_blocks);
        end


        dialogH.apply();
    end

    function update_highlighting(system,reqs_modified,filter_modified,update_sysreq_blocks)

        modelH=rmisl.getmodelh(system);
        if~isempty(modelH)
            rehighlighted=false;
            if filter_modified

                rehighlighted=false;
                if strcmp(get_param(modelH,'ReqHilite'),'on')
                    rmisl.highlight(modelH);
                    if ispc
                        reqmgt('winFocus','Requirements Settings');
                    end
                    rehighlighted=true;
                end
            end



            if update_sysreq_blocks&&~rehighlighted
                rmidispblock('updateall',modelH,reqs_modified);
                if ispc
                    reqmgt('winFocus','Requirements Settings');
                end
            end
        end
    end
end

function storageTab=makeStorageOptionsTab(licensed)

    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels=storageOptionsLabels();
    end

    storageTab.Name=staticLabels.storageTabName;
    storageTab.Tag='storageTab';

    if dig.isProductInstalled('Simulink')&&is_simulink_loaded()

        note1.Name=staticLabels.note1;
        note1.Type='text';
        note1.Tag='note1';

        if licensed
            note2.Name=staticLabels.note2;
        else
            note2.Name=staticLabels.noLicense;
        end
        note2.Type='text';
        note2.Tag='note2';

        notesGroup.Type='group';
        notesGroup.Name=staticLabels.notesGroup;
        notesGroup.Items={note1,note2};
        notesGroup.Tag='notesGroup';

        storageRadio.Type='radiobutton';
        storageRadio.Tag='storageRadio';
        storageRadio.Name=staticLabels.storageRadio;
        storageRadio.Value=0+rmi.settings_mgr('get','storageSettings','external');
        storageRadio.Values=[0,1];
        storageRadio.Entries={staticLabels.storageRadioInternal,staticLabels.storageRadioExternal};
        storageRadio.MatlabMethod='feval';
        storageRadio.MatlabArgs={@storage_setting_changed,'%dialog'};
        storageRadio.Enabled=licensed;

        copyRadio.Type='radiobutton';
        copyRadio.Tag='copyRadio';
        copyRadio.Name=staticLabels.copyRadio;
        copyRadio.Entries={staticLabels.copyRadioHighlighted,staticLabels.copyRadioAlways};
        copyRadio.Values=[0,1];
        copyRadio.Value=0+rmi.settings_mgr('get','storageSettings','duplicateOnCopy');
        copyRadio.MatlabMethod='feval';
        copyRadio.MatlabArgs={@copy_setting_changed,'%dialog'};
        copyRadio.Enabled=licensed;

        storageTab.Items={...
        notesGroup,...
        storageRadio,...
        copyRadio};
    else
        storageTab.Enabled=0;
    end


    function out=storageOptionsLabels()
        out.storageTabName=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:Storage'));
        out.storageRadio=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:DefaultStorageLocation'));
        out.storageRadioInternal=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StoreInternally'));
        out.storageRadioExternal=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StoreExternally'));
        out.notesGroup=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StorageNotes'));
        out.note1=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StorageNote1'));
        out.note2=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StorageNote2'));
        out.noLicense=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:StorageNoLicense'));
        out.copyRadio=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ObjCopyHeader'));
        out.copyRadioAlways=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ObjCopyAlways'));
        out.copyRadioHighlighted=getString(message('Slvnv:reqmgt:Settings:getDialogSchema:ObjCopyHighlighted'));
    end

    function storage_setting_changed(dialogH)

        rmipref('StoreDataExternally',logical(dialogH.getWidgetValue('storageRadio')));

        dialogH.apply();
    end

    function copy_setting_changed(dialogH)
        newValue=dialogH.getWidgetValue('copyRadio');
        rmipref('DuplicateOnCopy',newValue);

        dialogH.apply();
    end

end


