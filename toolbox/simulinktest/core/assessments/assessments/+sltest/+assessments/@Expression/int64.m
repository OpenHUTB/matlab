function res=int64(expr)



    try
        res=sltest.assessments.Cast(expr,'int64');
    catch ME
        ME.throwAsCaller();
    end
end
