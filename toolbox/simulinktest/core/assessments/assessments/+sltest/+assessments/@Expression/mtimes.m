function expr=mtimes(left,right)



    try
        expr=sltest.assessments.Mtimes(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
