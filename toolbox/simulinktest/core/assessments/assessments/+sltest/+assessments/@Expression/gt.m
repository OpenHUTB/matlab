function expr=gt(left,right)



    try
        expr=sltest.assessments.Gt(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
