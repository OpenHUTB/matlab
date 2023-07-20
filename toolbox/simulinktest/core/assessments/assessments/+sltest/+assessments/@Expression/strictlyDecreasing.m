function expr=strictlyDecreasing(self)



    try
        expr=sltest.assessments.StrictlyDecreasing(self);
    catch ME
        ME.throwAsCaller();
    end
end

