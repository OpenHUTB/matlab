
function dlg=getDialogSchema(this,~)




    dlg.DialogTitle=this.dialogTitle;
    dlg.DialogTag=this.dialogTag;
    dlg.PreApplyMethod='preApply';
    dlg.PostApplyMethod='postApply';
    dlg.DialogRefresh=true;
    dlg.HelpMethod='cvi.ResultsExplorer.ResultsExplorer.helpFcn';
    dlg.HelpArgs={};
    tag=this.widgetTag;
    widgetId=tag;

    dlg.Items={getPanelBuildFilter(this,tag,widgetId)};

    function panel=getPanelBuildFilter(this,tag,widgetId)

        groupFilterState=getFilterStateGroup(this,tag,widgetId);
        filterReport.Name=DAStudio.message('Slvnv:simcoverage:covFilterUpdateReport');
        filterReport.Type='pushbutton';
        filterReport.RowSpan=[1,1];
        filterReport.ColSpan=[3,3];
        filterReport.ObjectMethod='filterReportCallback';
        filterReport.Tag=[tag,'filterReport'];
        filterReport.WidgetId=[widgetId,'filterReport'];
        filterReport.Enabled=this.attachToData;
        filterReport.Visible=SlCov.CoverageAPI.feature('justification');

        filterAttachToData.Name=DAStudio.message('Slvnv:simcoverage:covFilterAttachToData');
        filterAttachToData.Type='checkbox';
        filterAttachToData.ObjectProperty='attachToData';
        filterAttachToData.RowSpan=[1,1];
        filterAttachToData.ColSpan=[2,2];
        filterAttachToData.DialogRefresh=true;
        filterAttachToData.Mode=true;
        filterAttachToData.Enabled=~isempty(cvresults(this.modelName));
        filterAttachToData.Tag=[tag,'filterAttachToData'];
        filterAttachToData.WidgetId=[widgetId,'filterAttachToData'];
        filterAttachToData.Visible=SlCov.CoverageAPI.feature('justification');


        filterSaveToModel.Name=DAStudio.message('Slvnv:simcoverage:covFilterAttachToModel');
        filterSaveToModel.Type='checkbox';
        filterSaveToModel.ObjectProperty='saveToModel';
        filterSaveToModel.RowSpan=[1,1];
        filterSaveToModel.ColSpan=[1,1];
        filterSaveToModel.Tag=[tag,'filterSaveToModel'];
        filterSaveToModel.WidgetId=[widgetId,'filterSaveToModel'];


        filterFileName.Name=DAStudio.message('Slvnv:simcoverage:covFilterFilename');
        filterFileName.Type='edit';
        filterFileName.Value=this.fileName;
        filterFileName.RowSpan=[2,2];
        filterFileName.ColSpan=[1,2];
        filterFileName.Tag=[tag,'filterFilename'];
        filterFileName.WidgetId=[widgetId,'filterFilename'];
        filterFileName.MatlabMethod='filterFileChangeCallback';
        filterFileName.MatlabArgs={this,'%dialog',filterFileName.Tag};



        filterFileBrowse.Name=DAStudio.message('Slvnv:simcoverage:covFilterBrowse');
        filterFileBrowse.Type='pushbutton';
        filterFileBrowse.RowSpan=[2,2];
        filterFileBrowse.ColSpan=[3,3];
        filterFileBrowse.Tag=[tag,'filterFileBrowse'];
        filterFileBrowse.WidgetId=[widgetId,'filterFileBrowse'];
        filterFileBrowse.MatlabMethod='filterFileBrowseCallback';
        filterFileBrowse.MatlabArgs={this,'%dialog'};



        groupFile.Type='group';
        groupFile.Name=DAStudio.message('Slvnv:simcoverage:covFilterSave');
        groupFile.Flat=true;
        groupFile.Items={filterSaveToModel,filterFileName,filterFileBrowse,filterReport,filterAttachToData};
        groupFile.LayoutGrid=[2,2];
        groupFile.RowSpan=[3,3];
        panel.LayoutGrid=[3,3];
        panel.RowStretch=[1,0,0];
        panel.Type='panel';
        panel.Items={groupFilterState,groupFile};
