function res=half(expr)



    try
        res=sltest.assessments.Cast(expr,'half');
    catch ME
        ME.throwAsCaller();
    end
end