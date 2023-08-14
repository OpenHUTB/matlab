function dlg = findDialog(blockSID)
    tag = DAStudio.message('sltest:fuzzer:FuzzerSchemeTag') + "_" + blockSID;
    dlg = [];
    for d=DAStudio.ToolRoot.getOpenDialogs()'
        if strcmp(d.dialogTag, tag)
            dlg = d;
        end
    end 
end
