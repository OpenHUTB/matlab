function utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,newBaseline)






    if(~isempty(newBaseline.time.total))
        mdladvObj.UserData.Progress.baseLineOverall=newBaseline;

        if isempty(mdladvObj.UserData.Results.baselines)
            mdladvObj.UserData.Results.baselines=newBaseline;
        else
            mdladvObj.UserData.Results.baselines(end+1)=newBaseline;
        end
    else
        mdladvObj.UserData.Progress.baseLineOverall=baseLineBefore;
    end



    baseLine.before=baseLineBefore;
    baseLine.after=newBaseline;

    currentCheck.ResultData.before=baseLine.before;
    currentCheck.ResultData.after=baseLine.after;

    mdladvObj.UserData.Results.currentCheckName=newBaseline.check.name;


