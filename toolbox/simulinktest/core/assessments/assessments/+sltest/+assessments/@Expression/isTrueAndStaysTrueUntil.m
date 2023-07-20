function expr=isTrueAndStaysTrueUntil(self,duration,other)


    try
        expr=sltest.assessments.IsTrueAndStaysTrueUntil(self,duration,other);
    catch ME
        ME.throwAsCaller();
    end
end

