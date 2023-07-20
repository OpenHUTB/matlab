function expr=staysTrueFor(self,delay)



    try
        expr=sltest.assessments.StaysTrueFor(delay,self);
    catch ME
        ME.throwAsCaller();
    end
end