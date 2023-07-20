function expr=becomesTrueAndStaysTrueForAtMost(self,duration)


    try
        expr=sltest.assessments.BecomesTrueAndStaysTrueForAtMost(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

