function expr=increasing(self)



    try
        expr=sltest.assessments.Increasing(self);
    catch ME
        ME.throwAsCaller();
    end
end

