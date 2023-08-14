


function result=CGAModelCheck(hSys)
    [successful,resultCellArray]=coder.advisor.internal.runBuildAdvisor(hSys,0,1);

    if successful
        result.successful=true;
    else
        result.successful=false;
    end

    result.checkResult=resultCellArray;
end
