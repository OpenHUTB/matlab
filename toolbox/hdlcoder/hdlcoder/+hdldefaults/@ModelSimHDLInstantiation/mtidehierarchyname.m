function[path,name]=mtidehierarchyname(this,namestr)







    sep=find(namestr=='/');
    if~isempty(sep)
        path=namestr(1:sep(end));
        if path(1)~='/'
            path=['/',path];
        end
        name=namestr(sep(end)+1:end);
    else
        path='';
        name=namestr;
    end


