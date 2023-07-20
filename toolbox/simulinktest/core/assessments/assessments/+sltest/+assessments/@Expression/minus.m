function expr=minus(left,right)



    try
        expr=sltest.assessments.Minus(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
