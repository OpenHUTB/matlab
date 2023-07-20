function expr=le(left,right)



    try
        expr=sltest.assessments.Le(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
