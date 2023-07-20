function res=logical(expr)



    try
        res=sltest.assessments.Cast(expr,'logical');
    catch ME
        ME.throwAsCaller();
    end
end
