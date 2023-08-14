
function refreshHarnessListDlg(targetModel)

    currDlgList=DAStudio.ToolRoot.getOpenDialogs();
    for j=1:numel(currDlgList)
        currDlg=currDlgList(j);
        currSrc=currDlg.getSource();
        if strcmp(currDlg.dialogTag,'HarnessListDlgTag')&&strcmp(getfullname(currSrc.mdlH),targetModel)
            if currSrc.selIdx==numel(currSrc.ownerList)
                selection='';
            else
                selection=currDlg.getComboBoxText('HarnessListOwnerSelector');
            end
            currSrc.updateList(selection);
            currDlg.refresh;
            currSrc.updateEnabled(currDlg);
            break;
        end
    end
end