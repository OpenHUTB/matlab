function expr=staysTrueForAtMost(self,delay)



    try
        expr=sltest.assessments.StaysTrueForAtMost(delay,self);
    catch ME
        ME.throwAsCaller();
    end
end