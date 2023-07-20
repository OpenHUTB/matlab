function expr=isTrueAndStaysTrueForAtLeast(self,duration)


    try
        expr=sltest.assessments.IsTrueAndStaysTrueForAtLeast(duration,self);
    catch ME
        ME.throwAsCaller();
    end
end

