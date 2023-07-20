function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok




    sizeOutportNum=length(outportNum);

    if sizeOutportNum==0

        pathItems={};
    else
        pathItems=cell(sizeOutportNum,1);

        for idxout=1:sizeOutportNum
            switch outportNum(idxout)
            case 1
                if strcmp(blkObj.coeffOutFcnActive,'K')
                    pathItems{idxout}='K';
                else
                    pathItems{idxout}='A';
                end
            case 2
                if strcmp(blkObj.coeffOutFcnActive,'A and K')
                    pathItems{idxout}='K';
                else
                    pathItems{idxout}='P';
                end
            case 3
                pathItems{idxout}='P';
            end
        end
    end
