function res=int32(expr)



    try
        res=sltest.assessments.Cast(expr,'int32');
    catch ME
        ME.throwAsCaller();
    end
end
