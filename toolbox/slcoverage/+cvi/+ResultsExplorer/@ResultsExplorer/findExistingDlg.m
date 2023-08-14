function obj=findExistingDlg(topModelName)





    obj=[];
    activeModel=SlCov.CoverageAPI.resolveModelUnderTest(topModelName);
    mes=find(DAStudio.Root,'-isa','DAStudio.Explorer');
    for idx=1:numel(mes)
        me=mes(idx);
        try
            dialogTag=cvi.ResultsExplorer.ResultsExplorer.getDialogTag(activeModel);
            if isa(me.getRoot,'SlCovResultsExplorer.Root')&&...
                strcmpi(dialogTag,me.getRoot.m_impl.resultsExplorer.dialogTag)
                obj=me.getRoot.m_impl.resultsExplorer;
                break;
            end
        catch MEx %#ok<NASGU>
        end
    end

end