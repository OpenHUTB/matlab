function expr=eventually(interval,self)



    try
        expr=sltest.assessments.Eventually(interval,self);
    catch ME
        ME.throwAsCaller();
    end
end
