function pathName=normalizePathName(~,pathName)




    if~isempty(pathName)
        if pathName(end)=='/'
            pathName(end)='';
        end
        if pathName(1)=='/'
            pathName(1)='';
        end

    end
