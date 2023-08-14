function expr=ifThenAfterAtMost(left,right,duration)



    try
        expr=sltest.assessments.IfThenForAtMost(left,right,duration);
    catch ME
        ME.throwAsCaller();
    end
end


