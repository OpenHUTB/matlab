function TrackOSPAMetric(obj)



    if isR2021bOrEarlier(obj.ver)



        srcBlock='trackmetricslib/Optimal Subpattern Assignment Metric';
        paramsToRemove={'Metric',...
        'WindowLength',...
        'WindowSumOrder',...
        'WindowWeights',...
        'WindowWeightExponent',...
        'CustomWeights'};
        RemoveRule={...
        slexportprevious.rulefactory.removeInstanceParameter(...
        ['<SourceBlock|"',srcBlock,'">'],paramsToRemove,obj.ver)};
        obj.appendRules(RemoveRule);
    end

    if isR2020bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('trackmetricslib/Optimal Subpattern Assignment Metric');
    end

end