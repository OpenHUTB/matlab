function expr=plus(left,right)



    try
        expr=sltest.assessments.Plus(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
