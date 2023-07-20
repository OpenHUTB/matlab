function expr=decreasing(self)



    try
        expr=sltest.assessments.Decreasing(self);
    catch ME
        ME.throwAsCaller();
    end
end

