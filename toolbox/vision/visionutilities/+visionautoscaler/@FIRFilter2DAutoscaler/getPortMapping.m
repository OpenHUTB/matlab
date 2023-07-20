function pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)%#ok








    sizeOutportNum=length(outportIdx);

    if sizeOutportNum==0

        pathItems={};
    else
        pathItems=cell(sizeOutportNum,1);






        pathItems{1}='Output';
    end


