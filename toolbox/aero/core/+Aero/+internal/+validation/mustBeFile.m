function mustBeFile(files)





    idx=arrayfun(@isOpenable,files);


    if~all(idx)
        mustBeFile(files(~idx))
    end

end

function tf=isOpenable(file)
    fid=fopen(file);
    if fid==-1
        tf=false;
    else
        tf=true;
        fclose(fid);
    end
end