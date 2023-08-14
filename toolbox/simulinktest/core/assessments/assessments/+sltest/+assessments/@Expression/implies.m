function expr=implies(left,right)



    try
        expr=sltest.assessments.Implies(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
