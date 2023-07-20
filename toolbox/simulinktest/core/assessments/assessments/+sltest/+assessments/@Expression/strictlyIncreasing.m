function expr=strictlyIncreasing(self)



    try
        expr=sltest.assessments.StrictlyIncreasing(self);
    catch ME
        ME.throwAsCaller();
    end
end

