function fileName=mergeFilters(filterName1,filterName2)





    if isempty(filterName1)
        fileName=filterName2;
        return;
    elseif isempty(filterName2)
        fileName=filterName1;
        return;
    end
    filter1=slcoverage.Filter(filterName1);
    filter2=slcoverage.Filter(filterName2);
    allRules=filter2.rules;
    for idx=1:numel(allRules)
        filter1.addRule(allRules(idx));
    end
    fileName=tempname;
    filter1.save(fileName);
