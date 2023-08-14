function cacheReuseInfo(h)








    reuseMap=zeros(size(h.SystemMap));
    reuseInfo=h.ReuseInfo;
    len=length(h.SystemMap);
    for k=1:length(reuseInfo)
        sysnum=reuseInfo(k).SystemID;
        if sysnum>0&&sysnum<len

            reuseSys=sscanf(reuseInfo(k).ReuseFlag,'Reusable Function(S%d)');
            if~isempty(reuseSys)
                index=sysnum+1;
                if reuseSys==sysnum
                    reuseMap(index)=-1;
                else
                    reuseMap(index)=k;
                end
            end
        end
    end
    h.ReuseMap=reuseMap;
