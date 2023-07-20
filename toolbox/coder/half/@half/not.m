function out=not(in)
    try
        out=~single(in);
    catch ex
        throwAsCaller(ex);
    end
end

