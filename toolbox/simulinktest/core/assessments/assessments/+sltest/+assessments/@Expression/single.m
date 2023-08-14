function res=single(expr)



    try
        res=sltest.assessments.Cast(expr,'single');
    catch ME
        ME.throwAsCaller();
    end
end
