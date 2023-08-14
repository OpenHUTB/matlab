function ret=hasCoverageResults(resultObj)








    ret=false;
    if stm.internal.hasCoverageResults(resultObj.getResultID)
        ret=true;
    end
end
