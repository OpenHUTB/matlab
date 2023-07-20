function res=uint16(expr)



    try
        res=sltest.assessments.Cast(expr,'uint16');
    catch ME
        ME.throwAsCaller();
    end
end
