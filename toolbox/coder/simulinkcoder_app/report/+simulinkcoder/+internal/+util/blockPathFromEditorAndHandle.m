function blockPath=blockPathFromEditorAndHandle(editor,handle)

    blockPath=Simulink.BlockPath();

    hs=GLUE2.HierarchyService;

    currentHid=editor.getHierarchyId();

    while hs.isValid(currentHid)
        obj=hs.getM3IObject(currentHid);
        target=obj.temporaryObject;
        if isa(target,'SLM3I.Block')&&target.isModelReference

            blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(hs.getParent(currentHid),target.handle);
            break;
        end

        currentHid=hs.getParent(currentHid);
    end


    cells=blockPath.convertToCell;


    if~strcmp(get_param(handle,'Type'),'block_diagram')
        obj=get_param(handle,'object');
        blockPath=Simulink.BlockPath([cells;obj.getFullName()]);
    end