function dlg=findDialog(tag,harnessOwner)

    dlg=[];
    for d=DAStudio.ToolRoot.getOpenDialogs()'
        if strcmp(d.dialogTag,tag)
            src=d.getSource();
            if src.harnessOwner==harnessOwner
                dlg=d;
                return;
            end
        end
    end
end

