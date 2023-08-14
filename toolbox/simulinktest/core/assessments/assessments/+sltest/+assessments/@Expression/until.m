function expr=until(self,interval,other)



    try
        expr=sltest.assessments.Until(self,interval,other);
    catch ME
        ME.throwAsCaller();
    end
end
