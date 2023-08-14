function expr=or(left,right)



    try
        expr=sltest.assessments.Or(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
