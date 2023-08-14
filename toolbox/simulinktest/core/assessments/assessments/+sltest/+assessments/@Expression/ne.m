function expr=ne(left,right)



    try
        expr=sltest.assessments.Ne(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
