function expr=staysTrueForBetween(self,delay)



    try
        expr=sltest.assessments.StaysTrueForBetween(delay,self);
    catch ME
        ME.throwAsCaller();
    end
end