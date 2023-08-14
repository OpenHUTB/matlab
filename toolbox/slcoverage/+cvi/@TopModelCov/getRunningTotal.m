
function res=getRunningTotal(modelCovObjs,prev)

    allTestIds=cv('get',modelCovObjs,'.currentTest')';
    rootIds=cv('get',allTestIds,'.linkNode.parent');
    rts='.runningTotal';
    if prev
        rts='.prevRunningTotal';
    end

    runningTotals=cv('get',rootIds,rts);
    runningTotals(runningTotals==0)=[];
    runningTotals=num2cell(runningTotals');
    res=[];
    if~isempty(runningTotals)
        if length(runningTotals)==1
            res=cvdata(runningTotals{:});
        else
            res=cv.cvdatagroup(runningTotals{:});
        end
    end
end

