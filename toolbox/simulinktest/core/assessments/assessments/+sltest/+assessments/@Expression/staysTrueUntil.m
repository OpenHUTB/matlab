function expr=staysTrueUntil(left,duration,right)



    try
        expr=sltest.assessments.StaysTrueUntil(left,duration,right);
    catch ME
        ME.throwAsCaller();
    end
end