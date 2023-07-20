function obj=hide(topModelName)




    obj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelName);
    if~isempty(obj)
        obj.explorer.hide;
    end
end