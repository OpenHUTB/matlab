function editor=findExistingDlg(model,dialogTag)



    tr=DAStudio.ToolRoot;
    dlgs=tr.getOpenDialogs;
    editor=[];

    for idx=1:numel(dlgs)
        dlg=dlgs(idx);
        if strcmp(dlg.dialogTag,dialogTag)&&isequal(dlg.getSource.model,model)
            editor=dlg.getSource;
            break;
        end
    end
end