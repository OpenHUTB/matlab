function expr=staysTrueForAtLeast(self,delay)



    try
        expr=sltest.assessments.StaysTrueForAtLeast(delay,self);
    catch ME
        ME.throwAsCaller();
    end
end