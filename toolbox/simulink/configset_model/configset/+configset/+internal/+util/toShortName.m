function[name,comp]=toShortName(fullname)



    f=strfind(fullname,':');
    if~isempty(f)
        name=fullname(f+1:end);
        comp=fullname(1:f-1);
    else
        name=fullname;
        comp='';
    end



