function expr=afterBetweenDelay(duration,self)

    try
        expr=sltest.assessments.AfterBetweenDelay(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end
