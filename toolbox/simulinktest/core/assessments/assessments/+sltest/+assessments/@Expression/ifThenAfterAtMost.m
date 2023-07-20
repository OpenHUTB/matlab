function expr=ifThenAfterAtMost(left,right,duration)



    try
        expr=sltest.assessments.IfThenAfterAtMost(left,right,duration);
    catch ME
        ME.throwAsCaller();
    end
end


