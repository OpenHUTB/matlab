

function flag=isParent(pstr,cstr)
    flag=true;
    pstrC=textscan(pstr,'%s','Delimiter','/');
    cstrC=textscan(cstr,'%s','Delimiter','/');

    if length(pstrC{1})>=length(cstrC{1})
        flag=false;
        return;
    end
    for i=1:length(pstrC{1})
        if~strcmp(pstrC{1}{i},cstrC{1}{i})
            flag=false;
            return;
        end
    end
end