function expr=rise(self,delay,relativeValue)



    try
        expr=sltest.assessments.Rise(delay,self,relativeValue);
    catch ME
        ME.throwAsCaller();
    end
end

