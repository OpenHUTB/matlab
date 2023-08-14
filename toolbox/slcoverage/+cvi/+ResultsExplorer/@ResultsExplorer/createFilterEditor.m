function createFilterEditor(obj)




    obj.filterEditor=SlCov.FilterEditor.createFilterEditor(obj.topModelName,'');
    obj.filterEditor.dialogTag=obj.dialogTag;
    obj.filterEditor.dialogTitle='';
    obj.filterEditor.widgetTag=obj.widgetTag;
    obj.filterEditor.fileName=obj.tempFilterFileName;
end