function testCaseName=getTestCaseName(testRunInfo,options)




    testCaseName=[];
    if~isempty(testRunInfo)&&~isempty(testRunInfo.runName)
        if isstruct(testRunInfo.testId)
            testId=testRunInfo.testId.uuid;
            runName=testRunInfo.runName;
            contextType=testRunInfo.testId.contextType;
        else
            testId=num2str(testRunInfo.runId);
            runName=testRunInfo.runName;
            contextType='ST';
        end
        if strcmpi(contextType,'RE')
            contextName=getString(message('Slvnv:simcoverage:cvhtml:OpenTestInContextRE'));
        elseif strcmpi(contextType,'ST')
            contextName=getString(message('Slvnv:simcoverage:cvhtml:OpenTestInContextST'));
        end

        testCaseName=sprintf('<a title="%s" href="matlab: cvi.ReportUtils.reportContextCallBack(''run'', ''%s'', ''%s'', ''%s'');">%s</a>',...
        contextName,testId,contextType,options.topModelName,runName);
    end
end