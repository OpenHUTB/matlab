function expr=ge(left,right)



    try
        expr=sltest.assessments.Ge(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
