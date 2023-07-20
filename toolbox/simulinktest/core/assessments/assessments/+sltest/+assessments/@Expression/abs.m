function expr=abs(self)



    try
        expr=sltest.assessments.Abs(self);
    catch ME
        ME.throwAsCaller();
    end
end
