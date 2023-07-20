function expr=eq(left,right)



    try
        expr=sltest.assessments.Eq(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
