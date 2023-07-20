function expr=impliesAlways(left,right)



    try
        expr=sltest.assessments.ImpliesAlways(left,right);
    catch ME
        ME.throwAsCaller();
    end
end
