function out=getCodeLocations(h,block)




    reg=h.getRegistry(block);
    if~isempty(reg)
        out=reg.location;
    else
        out=[];
    end