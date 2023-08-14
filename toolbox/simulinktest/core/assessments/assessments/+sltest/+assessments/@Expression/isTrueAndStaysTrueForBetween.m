function expr=isTrueAndStaysTrueForBetween(self,duration)


    try
        expr=sltest.assessments.IsTrueAndStaysTrueForBetween(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

