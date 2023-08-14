function root=getCodeGenRoot(editor)


    root=[];
    hids=GLUE2.HierarchyService.split(editor.getHierarchyId());
    for i=1:length(hids)
        hid=hids(i);
        topLevel=GLUE2.HierarchyService.getTopLevel(hid);
        mdl=SLM3I.HierarchyServiceUtils.getHandle(topLevel);
        cgb=get_param(mdl,'CodeGenBehavior');
        if strcmp(cgb,'Default')
            root=mdl;
            return;
        end
    end

