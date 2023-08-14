function res=uint8(expr)



    try
        res=sltest.assessments.Cast(expr,'uint8');
    catch ME
        ME.throwAsCaller();
    end
end
