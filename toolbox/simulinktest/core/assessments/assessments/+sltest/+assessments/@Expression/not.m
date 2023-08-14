function expr=not(self)



    try
        expr=sltest.assessments.Not(self);
    catch ME
        ME.throwAsCaller();
    end
end
