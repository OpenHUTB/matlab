function baselineAfter=utilGetBaselineAfter(~,~,check)


    baseLine=check.ResultData;

    hasAfter=isfield(check.ResultData,'after');

    if(isempty(baseLine)||~hasAfter)
        baselineAfter=utilCreateEmptyBaseline();
    else
        baselineAfter=baseLine.after;
    end

