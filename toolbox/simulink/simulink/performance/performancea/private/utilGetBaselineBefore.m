function baseLineBefore=utilGetBaselineBefore(mdladvObj,~,check)


    baseLine=check.ResultData;

    hasBefore=isfield(check.ResultData,'before');



    if(~hasBefore||isempty(baseLine))||(isempty(baseLine.before.time.total)&&isempty(baseLine.after.time.total))
        baseLine.before=utilGetOverallBaseline(mdladvObj);
    end

    baseLineBefore=baseLine.before;




