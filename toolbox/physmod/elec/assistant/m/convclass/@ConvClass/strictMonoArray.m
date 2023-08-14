function out=strictMonoArray(array)



    out=array;
    if~isvector(array)
        return
    else
        for i=2:numel(array)
            out(i)=out(i)+eps*i;
        end
    end
end
