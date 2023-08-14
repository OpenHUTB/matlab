function pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)%#ok








    sizeOutportNum=length(outportIdx);

    if sizeOutportNum==0

        pathItems={};
    else
        pathItems=cell(sizeOutportNum,1);


        for idxout=1:sizeOutportNum
            switch outportIdx(idxout)
            case 1



                if strcmp(blkObj.output,'SAD values')
                    pathItems{idxout}='Output';
                else
                    pathItems{idxout}='';
                end
            case 2


                pathItems{idxout}='Output';

            case 3


                pathItems{idxout}='';
            end
        end
    end


