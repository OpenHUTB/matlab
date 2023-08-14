function blockPath=gcbp()









    blockPath=Simulink.BlockPath;

    h=gcbh;
    if ishandle(h)
        lastActiveEditor=SLM3I.SLDomain.getLastActiveEditorFor(get_param(get_param(h,'parent'),'handle'));
        if(~isempty(lastActiveEditor))


            parentHid=lastActiveEditor.getHierarchyId;
            blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(parentHid,h);
        else


            path=gcb;
            if(~isempty(path))
                blockPath=Simulink.BlockPath(path);
            end
        end
    end

end

