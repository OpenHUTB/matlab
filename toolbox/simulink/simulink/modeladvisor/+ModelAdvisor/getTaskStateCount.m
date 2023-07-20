function count=getTaskStateCount(tasks)

    if iscell(tasks)

        tasks=[tasks{:}];
    end

    enumList=enumeration(ModelAdvisor.CheckStatus.NotRun);
    for i=1:length(enumList)
        count.(char(enumList(i)))=sum([tasks(:).state]==enumList(i));
    end

end