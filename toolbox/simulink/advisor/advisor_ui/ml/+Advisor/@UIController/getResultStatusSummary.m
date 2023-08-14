function result=getResultStatusSummary(this)
    statuses=enumeration(ModelAdvisor.CheckStatus.Passed);
    result={};
    for i=1:numel(statuses)

        if statuses(i)==ModelAdvisor.CheckStatus.Informational
            continue;
        end

        statusString=ModelAdvisor.CheckStatusUtil.getText(statuses(i));
        result{end+1,1}=statusString;
        result{end,2}=['/',ModelAdvisor.CheckStatusUtil.getIcon(statuses(i),'resultdetails')];
    end
end