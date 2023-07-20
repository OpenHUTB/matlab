function pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)%#ok








    sizeOutportNum=length(outportIdx);

    if sizeOutportNum==0

        pathItems={};
    else
        pathItems=cell(sizeOutportNum,1);


        for idxout=1:sizeOutportNum
            switch outportIdx(idxout)
            case 1


                pathItems{idxout}='';
            case 2



                if strcmp(blkObj.threshOut,'off')&&strcmp(blkObj.effMetricOut,'on')
                    pathItems{idxout}='Eff Metric';
                else
                    pathItems{idxout}='';
                end
            case 3


                pathItems{idxout}='Eff Metric';
            end
        end
    end


