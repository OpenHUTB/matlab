function expr=impliesAfter(left,right,duration)

    try
        expr=sltest.assessments.ImpliesAfter(left,right,duration);
    catch ME
        ME.throwAsCaller();
    end
end

