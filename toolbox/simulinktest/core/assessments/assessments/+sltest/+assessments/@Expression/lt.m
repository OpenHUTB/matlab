function expr=lt(left,right)



    try
        expr=sltest.assessments.Lt(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
