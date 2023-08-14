function expr=risingEdge(self)



    try
        expr=sltest.assessments.RisingEdge(self);
    catch ME
        ME.throwAsCaller();
    end
end

