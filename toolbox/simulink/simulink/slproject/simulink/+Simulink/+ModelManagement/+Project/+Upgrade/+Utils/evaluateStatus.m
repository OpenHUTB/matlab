function status=evaluateStatus(task)




    switch task.state
    case ModelAdvisor.CheckStatus.NotRun
        status='NotRun';
    case ModelAdvisor.CheckStatus.Passed
        status='Pass';
    otherwise
        if task.Check.ErrorSeverity==100
            status='Error';
        else
            status='Fail';
        end
    end

end
