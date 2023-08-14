function res=double(expr)



    try
        res=sltest.assessments.Cast(expr,'double');
    catch ME
        ME.throwAsCaller();
    end
end
