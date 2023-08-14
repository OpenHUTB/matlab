function dlg=getDialogSchema(this,~)




    tabContainer=getTabContainer(this);

    dlg.DialogTag='CloneDetectionExclusionEditor';
    dlg.DialogTitle=DAStudio.message('sl_pir_cpp:creator:cloneDetectionExclusionEditor');
    dlg.PostApplyMethod='postApply';
    dlg.DialogRefresh=true;
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={fullfile(docroot,'slcheck','helptargets.map'),'CDExclusion_GUI_Help'};
    dlg.Items={tabContainer};
    dlg.DisplayIcon=fullfile('toolbox','sl_pir_cap','clone_detection_app','ui','images','detect_16.png');
    dlg.DialogTag=ModelAdvisor.ExclusionEditor.getDialogTag(this.fModelName);
    dlg.CloseMethod='CloseCB';
    dlg.ValidationCallback=@onDialogValidationCallback;
end

function tabContainer=getTabContainer(this)

    ModelExclusionTab=getExclusionsDialogSchema(this,'ModelExclusions','test',true);


    if~ModelAdvisor.getExpertMode
        ModelExclusionTab.Type='panel';
        tabContainer=ModelExclusionTab;
    else
        ModelExclusionTab.Tag=ModelAdvisor.ExclusionEditor.getDialogTag(this.fModelName);
        ModelExclusionTab.Name=DAStudio.message('ModelAdvisor:engine:ModelSpecificExclusions');

        GlobalExclusionTab=getExclusionsDialogSchema(this,'ModelExclusions','test',false);
        GlobalExclusionTab.Tag='GlobalExclusionTag';
        GlobalExclusionTab.Name=DAStudio.message('ModelAdvisor:engine:GlobalExclusions');

        tabContainer.Type='tab';
        tabContainer.Tag='Tab_Container';
        tabContainer.TabChangedCallback='tabChangeExclusionCallback';
        tabContainer.Tabs={ModelExclusionTab,GlobalExclusionTab};
        tabContainer.RowSpan=[1,4];
        tabContainer.ColSpan=[1,4];
        tabContainer.ActiveTab=this.activeTabIndex;
        ModelExclusionTab.DialogRefresh=true;
    end

end

function onDialogValidationCallback(dlg)
    this=dlg.getSource;

    if this.storeInSLX
        return;
    end
    fileName=dlg.getWidgetValue('ModelExclusionsModelExclusionFilename');


    if(strcmp(deblank(fileName),'')||strcmp(fileName,'<untitled.xml>'))&&~isempty(this.exclusionState.keys)
        [FileName,PathName]=uiputfile([this.fModelName,'_exclusions.xml'],...
        DAStudio.message('ModelAdvisor:engine:SaveExclusionFile'));

        if isequal(FileName,0)&&isequal(PathName,0)
            dlg.setWidgetWithError('ModelExclusionsModelExclusionFilename');
            return;
        end
        FileName=[PathName,FileName];
        if~checkXMLExt(dlg,FileName)
            return;
        end
        if~strcmp(get_param(bdroot(this.fModelName),'MAModelExclusionFile'),FileName)&&...
            strcmp(get_param(this.fModelName,'Lock'),'on')
            dlg.setWidgetWithError('ModelExclusionsModelExclusionFilename');
            msgbox(DAStudio.message('ModelAdvisor:engine:ExclusionLibraryLocked'));
            return;
        end

        this.fileName=FileName;
    else
        if isempty(this.exclusionState.keys)
            dlg.clearWidgetsWithError;
            return;
        end
        if~checkXMLExt(dlg,fileName)
            return;
        end
    end

    this.fDialogHandle.refresh;
    this.fDialogHandle.restoreFromSchema;
    dlg.clearWidgetWithError('ModelExclusionsModelExclusionFilename');
end

function isXML=checkXMLExt(dlg,FileName)
    isXML=true;
    [~,~,ext]=fileparts(FileName);
    if~strcmpi(ext,'.xml')
        isXML=false;
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('ModelAdvisor:engine:FileShouldBeXML'),'Error',true);
        dlg.setWidgetWithError('ModelExclusionsModelExclusionFilename');
    end
end
