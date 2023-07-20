function expr=isTrueAndStaysTrueForAtMost(self,duration)


    try
        expr=sltest.assessments.IsTrueAndStaysTrueForAtMost(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

