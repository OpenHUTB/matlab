function expr=risingStep(self,threshold)



    try
        expr=sltest.assessments.RisingStep(self,threshold);
    catch ME
        ME.throwAsCaller();
    end
end

