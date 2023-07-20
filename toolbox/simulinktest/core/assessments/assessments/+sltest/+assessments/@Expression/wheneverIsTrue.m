function expr=wheneverIsTrue(self)


    try
        expr=sltest.assessments.WheneverIsTrue(self);
    catch ME
        ME.throwAsCaller();
    end
end

