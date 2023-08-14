function shorterUrl=shortUrl(originalUrl)






    shorterUrl=originalUrl;

    all_slashes=strfind(originalUrl,'/');
    if length(all_slashes)<=3
        return;
    end

    proto=strfind(originalUrl,'://');
    if isempty(proto)
        return;
    end

    third_slash=all_slashes(3);
    last_slash=all_slashes(end);
    if last_slash==length(originalUrl)
        if length(all_slashes)==4
            return;
        end
        last_slash=all_slashes(end-1);
    end
    if last_slash>third_slash
        shorterUrl=[originalUrl(1:third_slash),'...',originalUrl(last_slash:end)];
    end
