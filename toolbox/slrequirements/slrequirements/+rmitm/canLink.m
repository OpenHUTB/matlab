function result=canLink(sourceId)






    result=false;

    if isempty(sourceId)
        return;

    elseif~any(sourceId=='|')
        return;

    else
        [fPath,remainder]=strtok(sourceId,'|');
        [~,~,ext]=fileparts(fPath);
        result=strcmp(ext,'.mldatx')&&~isempty(regexp(remainder,'^|[0-9a-f\-]+$')');
    end
end

