function expr=fallingEdge(self)



    try
        expr=sltest.assessments.FallingEdge(self);
    catch ME
        ME.throwAsCaller();
    end
end

