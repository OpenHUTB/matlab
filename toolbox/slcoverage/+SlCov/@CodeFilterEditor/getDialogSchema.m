function dlg=getDialogSchema(this,~)




    changeString='';
    if this.needSave
        changeString='*';
    end

    dlg.DialogTitle=[this.dialogTitle,changeString];
    dlg.DialogTag=this.dialogTag;
    dlg.MinMaxButtons=true;
    dlg.StandaloneButtonSet={'Apply','Revert'};
    dlg.EmbeddedButtonSet={'Apply','Revert'};
    dlg.PostApplyCallback='postApplyCallback';
    dlg.PostApplyArgs={this,'%dialog'};
    dlg.PostRevertCallback='postRevertCallback';
    dlg.PostRevertArgs={this,'%dialog'};
    dlg.CloseCallback='closeCallback';
    dlg.CloseArgs={this,'%dialog'};
    dlg.DialogRefresh=true;
    dlgTag=this.widgetTag;
    widgetId=dlgTag;

    dlg.Items={getPanelBuildFilter(this,dlgTag,widgetId)};


    function filterPanel=getPanelBuildFilter(this,dlgTag,widgetId)

        filterState=getFilterStateGroup(this,dlgTag,widgetId);

        if this.isUnknownFile
            filterFname=getString(message('Slvnv:simcoverage:cvresultsexplorer:NotSaved'));
            filterName=SlCov.CodeFilterEditor.defaultFileName(this.modelName);
        else
            [foundFileName,fullFileName]=SlCov.CodeFilterEditor.findFile(this.fileName,'');
            if isempty(foundFileName)
                filterFname=this.fileName;
            else
                filterFname=fullFileName;
            end
            filterName=this.filterName;
        end

        editName.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterName'));
        editName.Type='edit';
        editName.RowSpan=[1,1];
        editName.ColSpan=[1,6];
        editName.Source=this;
        editName.Value=filterName;
        editName.Tag=[dlgTag,'editName'];
        editName.WidgetId=[dlgTag,'editName'];
        editName.MatlabMethod='filterNameChangedCallback';
        editName.MatlabArgs={this};
        this.nameTag=editName.Tag;

        filterFileName.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:FileName')),' ',filterFname];
        filterFileName.Type='text';
        filterFileName.RowSpan=[2,2];
        filterFileName.ColSpan=[1,1];
        filterFileName.Tag=[dlgTag,'filterFilename'];
        filterFileName.WidgetId=[widgetId,'filterFilename'];
        filterFileName.PreferredSize=[750,-1];

        saveFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:SaveAs'));
        saveFilter.Type='hyperlink';
        saveFilter.Enabled=~this.hasUnappliedChanges;
        saveFilter.MatlabMethod='saveFilterCallback';
        saveFilter.MatlabArgs={this,'%dialog'};
        saveFilter.RowSpan=[3,3];
        saveFilter.ColSpan=[1,2];
        saveFilter.Tag=[dlgTag,'saveFilter'];
        saveFilter.WidgetId=[widgetId,'saveFilter'];
        saveFilter.DialogRefresh=true;

        loadFilter.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:LoadFilter'));
        loadFilter.Type='hyperlink';
        loadFilter.Enabled=~this.hasUnappliedChanges;
        loadFilter.MatlabMethod='loadFilterCallback';
        loadFilter.MatlabArgs={this,'%dialog'};
        loadFilter.RowSpan=[4,4];
        loadFilter.ColSpan=[1,1];
        loadFilter.Tag=[dlgTag,'loadFilter'];
        loadFilter.WidgetId=[widgetId,'loadFilter'];
        loadFilter.DialogRefresh=true;

        infoGroup.Type='panel';
        infoGroup.Flat=true;
        infoGroup.LayoutGrid=[4,6];
        infoGroup.RowSpan=[2,2];
        infoGroup.Items={editName,filterFileName,saveFilter,loadFilter};
        infoGroup.Tag=[dlgTag,'infoGroup'];
        infoGroup.WidgetId=[dlgTag,'infoGroup'];

        editDescr.Type='editarea';
        editDescr.RowSpan=[3,3];
        editDescr.ColSpan=[1,6];
        editDescr.Source=this;
        editDescr.Value=this.filterDescr;
        editDescr.MaximumSize=[1000,40];
        editDescr.Tag=[dlgTag,'editDescr'];
        editDescr.WidgetId=[dlgTag,'editDescr'];
        editDescr.MatlabMethod='filterDescriptionChangedCallback';
        editDescr.MatlabArgs={this};
        this.descriptionTag=editDescr.Tag;

        descrGroup.Type='group';
        descrGroup.Name=[getString(message('Slvnv:simcoverage:cvresultsexplorer:Description')),'  '];
        descrGroup.Flat=true;
        descrGroup.LayoutGrid=[3,6];
        descrGroup.RowSpan=[2,2];
        descrGroup.Items={editDescr};
        descrGroup.Tag=[dlgTag,'descrGroup'];
        descrGroup.WidgetId=[dlgTag,'descrGroup'];

        ruleGroup.Type='group';
        ruleGroup.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterRules'));
        ruleGroup.Flat=true;
        ruleGroup.RowSpan=[2,2];
        ruleGroup.Items={filterState};
        ruleGroup.Tag=[dlgTag,'descrGroup'];
        ruleGroup.WidgetId=[dlgTag,'descrGroup'];

        filterPanel.LayoutGrid=[3,3];
        filterPanel.RowStretch=[1,0,0];
        filterPanel.Type='panel';
        filterPanel.Items={infoGroup,descrGroup,ruleGroup};
        filterPanel.Name=getString(message('Slvnv:simcoverage:cvresultsexplorer:FilterPanel'));
        filterPanel.Tag=[dlgTag,'filterPanel'];
        filterPanel.WidgetId=[dlgTag,'filterPanel'];


