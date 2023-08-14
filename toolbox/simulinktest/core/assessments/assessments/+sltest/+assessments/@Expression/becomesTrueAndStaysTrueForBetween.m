function expr=becomesTrueAndStaysTrueForBetween(self,duration)


    try
        expr=sltest.assessments.BecomesTrueAndStaysTrueForBetween(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

