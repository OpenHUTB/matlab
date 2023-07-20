function expr=becomesTrue(self)


    try
        expr=sltest.assessments.BecomesTrue(self);
    catch ME
        ME.throwAsCaller();
    end
end

