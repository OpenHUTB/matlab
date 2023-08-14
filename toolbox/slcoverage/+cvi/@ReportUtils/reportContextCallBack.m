function reportContextCallBack(command,testId,contextType,topModelName)




    str='';
    switch command
    case 'run'
        if strcmpi(contextType,'RE')
            cvi.ResultsExplorer.ResultsExplorer.showNodeCallback(topModelName,testId);
        elseif strcmpi(contextType,'ST')
            stm.internal.util.highlightTestResult(testId);
        end
    otherwise
        str='bad command';
    end
    if~isempty(str)
        warndlg(str);
    end
end

