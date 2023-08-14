







function[out,prefix]=getShortIdFromLongId(id)

    [token,remain]=strtok(id,'~');
    if~isempty(remain)
        prefix=token;
        out=remain(2:end);
    else
        out=token;
        prefix='';
    end

end