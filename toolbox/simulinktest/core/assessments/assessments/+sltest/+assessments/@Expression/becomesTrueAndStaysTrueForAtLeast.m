function expr=becomesTrueAndStaysTrueForAtLeast(self,duration)


    try
        expr=sltest.assessments.BecomesTrueAndStaysTrueForAtLeast(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

