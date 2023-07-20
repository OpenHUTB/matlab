function expr=withNoDelay(self)


    try
        expr=sltest.assessments.WithNoDelay(self);
    catch ME
        ME.throwAsCaller();
    end
end
