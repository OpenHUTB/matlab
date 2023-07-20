function expr=ifThenForAtLeast(left,right,duration)



    try
        expr=sltest.assessments.IfThenForAtLeast(left,right,duration);
    catch ME
        ME.throwAsCaller();
    end
end


