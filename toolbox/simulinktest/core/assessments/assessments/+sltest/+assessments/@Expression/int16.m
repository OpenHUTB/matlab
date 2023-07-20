function res=int16(expr)



    try
        res=sltest.assessments.Cast(expr,'int16');
    catch ME
        ME.throwAsCaller();
    end
end
