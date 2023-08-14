
function refreshContextListDlg(targetModel)

    currDlgList=DAStudio.ToolRoot.getOpenDialogs();
    for j=1:numel(currDlgList)
        currDlg=currDlgList(j);
        currSrc=currDlg.getSource();
        if strcmp(currDlg.dialogTag,'CodeContextListDlgTag')&&strcmp(getfullname(currSrc.mdlH),targetModel)
            currSrc.updateList();
            currDlg.refresh;
            currSrc.updateEnabled(currDlg);
            break;
        end
    end
end