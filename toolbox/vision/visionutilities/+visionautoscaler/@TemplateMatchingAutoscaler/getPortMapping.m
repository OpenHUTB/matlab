function pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)%#ok








    sizeOutportNum=length(outportIdx);

    if sizeOutportNum==0

        pathItems={};
    else
        pathItems=cell(sizeOutportNum,1);

        for idxout=1:sizeOutportNum
            switch outportIdx(idxout)
            case 1



                if strcmp(blkObj.output,'Metric matrix')
                    pathItems{idxout}='Output';
                else
                    pathItems{idxout}='Loc';
                end
            case 2



                if strcmp(blkObj.nMetric,'on')

                    pathItems{idxout}='Output';
                else
                    pathItems{idxout}='ROIValid';
                end

            case 3

                if strcmp(blkObj.nMetric,'on')

                    pathItems{idxout}='NValid';
                else
                    pathItems{idxout}='ROIValid';
                end

            case 4


                pathItems{idxout}='ROIValid';
            end
        end
    end


