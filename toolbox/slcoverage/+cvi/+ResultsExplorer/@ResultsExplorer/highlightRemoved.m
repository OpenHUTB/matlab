function highlightRemoved(topModelName)




    obj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelName);
    if~isempty(obj)&&~isempty(obj.highlightedNode)
        obj.highlightChange(obj.highlightedNode,false);
    end
end