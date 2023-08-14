function res=int8(expr)



    try
        res=sltest.assessments.Cast(expr,'int8');
    catch ME
        ME.throwAsCaller();
    end
end
