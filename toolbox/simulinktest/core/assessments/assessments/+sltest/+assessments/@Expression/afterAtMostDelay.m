function expr=afterAtMostDelay(duration,self)

    try
        expr=sltest.assessments.AfterAtMostDelay(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end
