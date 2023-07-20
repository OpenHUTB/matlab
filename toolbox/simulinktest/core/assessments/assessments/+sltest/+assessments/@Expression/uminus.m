function expr=uminus(self)



    try
        expr=sltest.assessments.Uminus(self);
    catch ME
        ME.throwAsCaller();
    end
end
