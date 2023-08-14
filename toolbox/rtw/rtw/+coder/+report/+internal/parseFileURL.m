function[filepath,query]=parseFileURL(fileURL)









    filepath='';
    query='';

    if~strncmp(fileURL,'file:///',8)
        return
    end
    if ispc
        if strncmp(fileURL(8:end),'//',2)
            startIdx=8;
        else
            startIdx=9;
        end
    else

        startIdx=8;
    end
    if length(fileURL)<startIdx
        return
    end
    k=strfind(fileURL,'?');
    if isempty(k)
        k=strfind(fileURL,'#');
    end
    if~isempty(k)&&k(end)>0
        filepath=fileURL(startIdx:k(end)-1);
        query=fileURL(k(end):end);
    else
        filepath=fileURL(startIdx:end);
        query='';
    end
    if ispc
        filepath=strrep(filepath,'/','\');
    end

    filepath=strrep(filepath,'%20',' ');
    filepath=strrep(filepath,'%23','#');
    filepath=strrep(filepath,'%3F','?');
    filepath=strrep(filepath,'%25','%');
