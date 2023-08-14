function result=isAbsolutePath(pathstr)





    result=false;
    if~isempty(pathstr)
        isWIN=strncmpi(computer,'PC',2);
        if isWIN
            if length(pathstr)>=2&&(strncmp(pathstr,'\\',2)||strcmp(pathstr(2),':'))

                result=true;
            end
        else
            if strcmp(pathstr(1),filesep)
                result=true;
            end
        end
    end
end