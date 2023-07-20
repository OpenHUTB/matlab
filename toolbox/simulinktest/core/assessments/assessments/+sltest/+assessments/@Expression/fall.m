function expr=fall(self,delay,relativeValue)



    try
        expr=sltest.assessments.Fall(delay,self,relativeValue);
    catch ME
        ME.throwAsCaller();
    end
end

