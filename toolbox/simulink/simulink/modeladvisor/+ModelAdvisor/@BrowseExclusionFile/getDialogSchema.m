function dlg=getDialogSchema(obj)





    tag='SelExcFile';widgetId='SelExcFile';
    saveExclusion.Type='group';
    saveExclusion.Name='';
    saveExclusion.LayoutGrid=[1,3];
    saveExclusion.Flat=true;

    loadExclusionFile.Name=DAStudio.message('ModelAdvisor:engine:ExclusionLoad');
    loadExclusionFile.Type='pushbutton';
    loadExclusionFile.RowSpan=[1,1];
    loadExclusionFile.ColSpan=[1,1];
    loadExclusionFile.ObjectMethod='loadExclusionFile';
    loadExclusionFile.Tag=[tag,'ExclusionFileBrowse'];
    loadExclusionFile.WidgetId=[widgetId,'ExclusionFileBrowse'];

    saveAsExclusionFile.Name=DAStudio.message('ModelAdvisor:engine:ExclusionSaveAs');
    saveAsExclusionFile.Type='pushbutton';
    saveAsExclusionFile.RowSpan=[1,1];
    saveAsExclusionFile.ColSpan=[2,2];
    saveAsExclusionFile.ObjectMethod='saveAsExclusionFile';
    saveAsExclusionFile.Tag=[tag,'ExclusionFileSaveAs'];
    saveAsExclusionFile.WidgetId=[widgetId,'ExclusionFileSaveAs'];

    detachExclusionFile.Name=DAStudio.message('ModelAdvisor:engine:ExclusionDetach');
    detachExclusionFile.Type='pushbutton';
    detachExclusionFile.RowSpan=[1,1];
    detachExclusionFile.ColSpan=[3,3];
    detachExclusionFile.ObjectMethod='detachExclusionFile';
    if isempty(get_param(bdroot(obj.getExclusionEditor.fModelName),'MAModelExclusionFile'))
        detachExclusionFile.Enabled=false;
    end
    detachExclusionFile.Tag=[tag,'ExclusionFileDetach'];
    detachExclusionFile.WidgetId=[widgetId,'ExclusionFileDetach'];

    saveExclusion.Items={loadExclusionFile,saveAsExclusionFile,detachExclusionFile};

    dlg.Items={saveExclusion};
    dlg.DialogTag='selectExclusionFile';
    dlg.StandaloneButtonSet={''};
    dlg.EmbeddedButtonSet={''};
    dlg.DialogTitle=DAStudio.message('ModelAdvisor:engine:SelectExclusionFile');
    dlg.DialogRefresh=true;
    dlg.Sticky=1;
