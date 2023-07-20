function sharedListPorts=shareDataForSpecificPorts(h,blk,inportSet,outportSet)





    sharedListPorts='';
    if~isempty(blk)
        sharedListPorts=h.hShareDTSpecifiedPorts(blk,inportSet,outportSet);
    end
end
