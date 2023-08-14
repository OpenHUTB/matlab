function expr=globally(interval,self)



    try
        expr=sltest.assessments.Globally(interval,self);
    catch ME
        ME.throwAsCaller();
    end
end
