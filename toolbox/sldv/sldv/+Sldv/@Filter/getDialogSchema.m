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
    tag=this.widgetTag;
    widgetId=tag;

    dlg.Items={getPanelBuildFilter(this,tag,widgetId)};
end

function panel=getPanelBuildFilter(this,tag,widgetId)
    groupFilterState=getFilterStateGroup(this,tag,widgetId);

    if strcmpi(this.fileName,Sldv.Filter.defaultFileName)
        fileName=this.fileName;
    else
        [foundFileName,fullFileName]=Sldv.Filter.findFile(this.fileName,this.modelName);
        if isempty(foundFileName)
            fileName=this.fileName;
        else
            fileName=fullFileName;
        end
    end
    filterFileName.Name=[getString(message('Sldv:Filter:dvFilterFilename')),' ',fileName];
    filterFileName.Type='text';
    filterFileName.RowSpan=[1,1];
    filterFileName.ColSpan=[1,2];
    filterFileName.Tag=[tag,'filterFilename'];
    filterFileName.WidgetId=[widgetId,'filterFilename'];
    filterFileName.PreferredSize=[750,-1];

    saveFilter.Name=getString(message('Sldv:Filter:SaveFilter'));
    saveFilter.Type='hyperlink';
    saveFilter.Enabled=~this.hasUnappliedChanges;
    saveFilter.MatlabMethod='saveFilterCallback';
    saveFilter.MatlabArgs={this};
    saveFilter.RowSpan=[2,2];
    saveFilter.ColSpan=[1,1];
    saveFilter.Tag=[tag,'saveFilter'];
    saveFilter.WidgetId=[widgetId,'saveFilter'];
    saveFilter.DialogRefresh=true;

    loadFilter.Name=getString(message('Sldv:Filter:LoadFilter'));
    loadFilter.Type='hyperlink';
    loadFilter.Enabled=~this.hasUnappliedChanges;
    loadFilter.MatlabMethod='loadFilterCallback';
    loadFilter.MatlabArgs={this};
    loadFilter.RowSpan=[3,3];
    loadFilter.ColSpan=[1,1];
    loadFilter.Tag=[tag,'loadFilter'];
    loadFilter.WidgetId=[widgetId,'loadFilter'];
    loadFilter.DialogRefresh=true;

    groupFile.Type='group';
    groupFile.Items={filterFileName,saveFilter,loadFilter};
    groupFile.LayoutGrid=[3,2];
    groupFile.RowSpan=[1,3];

    panel.LayoutGrid=[3,3];
    panel.RowStretch=[1,0,0];
    panel.Type='panel';
    panel.Items={groupFilterState,groupFile};
end
