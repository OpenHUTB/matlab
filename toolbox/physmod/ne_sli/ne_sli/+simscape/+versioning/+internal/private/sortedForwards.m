function out=sortedForwards(fwds,pth)










    lv=strcmp({fwds.OldSimscapePath},pth);
    out=fwds(lv);
    [~,I]=sort([out.Version]);
    out=out(I);
end