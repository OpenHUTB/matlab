function codeFilter=convertToCodeFilter(modelFilter,cvd,varargin)





    rationaleTag='';
    if~isempty(varargin)
        rationaleTag=varargin{1};
    end

    codeFilter=slcoverage.Filter;
    cvdCode=cvd.codeCovData;
    modelRules=modelFilter.rules;
    for mri=1:length(modelRules)
        codeRules=convertToCodeRules(modelRules(mri),cvdCode,rationaleTag);
        for cri=1:length(codeRules)
            codeFilter.addRule(codeRules{cri});
        end
    end
end
