function handleEditorChanged(obj,cbinfo)


    if~isvalid(obj)
        return;
    end

    studio=obj.studio;
    editor=studio.App.getActiveEditor;

    hId=editor.getHierarchyId;
    path=GLUE2.HierarchyService.getPaths(hId);
    subPath=path{end};
    if strcmp(obj.preSub,subPath)==0
        obj.preSub=subPath;
        obj.switchModel(subPath);
    end

end

