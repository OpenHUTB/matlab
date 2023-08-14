function expr=isTrueWithin(self,delay)



    try
        expr=sltest.assessments.IsTrueWithin(delay,self);
    catch ME
        ME.throwAsCaller();
    end
end
