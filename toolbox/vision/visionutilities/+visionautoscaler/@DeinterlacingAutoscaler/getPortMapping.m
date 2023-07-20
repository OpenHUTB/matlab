function pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)%#ok











    sizeOutportNum=length(outportIdx);

    if sizeOutportNum==0

        pathItems={};
    else

        pathItems=cell(sizeOutportNum,1);


        if(strncmp(blkObj.method,'Linear ...',6))
            pathItems{1}='Output';
        else


            pathItems{1}='Out';
        end
    end


