function res=uint32(expr)



    try
        res=sltest.assessments.Cast(expr,'uint32');
    catch ME
        ME.throwAsCaller();
    end
end
