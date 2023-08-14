function out=validateIpAddress(addr)




    out=true;
    if~isempty(regexp(strtrim(addr),'^\d{1,3}(\.\d{1,3}){3}$','once'))
        ipVec=sscanf(addr,['%u','.','%u','.','%u','.','%u']);
        if~all(ipVec<=255)
            out=false;
        end
    else
        out=false;
    end
end
