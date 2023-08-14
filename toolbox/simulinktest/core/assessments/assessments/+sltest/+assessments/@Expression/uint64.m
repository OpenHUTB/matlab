function res=uint64(expr)



    try
        res=sltest.assessments.Cast(expr,'uint64');
    catch ME
        ME.throwAsCaller();
    end
end
