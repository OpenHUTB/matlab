function expr=isTrue(self)


    try
        expr=sltest.assessments.IsTrue(self);
    catch ME
        ME.throwAsCaller();
    end
end

