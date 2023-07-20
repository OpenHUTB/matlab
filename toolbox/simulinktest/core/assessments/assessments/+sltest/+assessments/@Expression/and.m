function expr=and(left,right)



    try
        expr=sltest.assessments.And(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
