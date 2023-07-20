function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok




    sizeInportNum=length(inportNum);
    sizeOutportNum=length(outportNum);
    pathItems=cell(sizeInportNum+sizeOutportNum,1);

    if sizeInportNum>0
        for idxin=1:sizeInportNum
            pathItems{idxin}='';
        end
    end

    if sizeOutportNum>0
        for idxout=1:sizeOutportNum
            switch outportNum(idxout)
            case 1
                pathItems{idxout}='Output Signal';
            case 2
                pathItems{idxout}='Error Signal';
            case 3
                if strcmp(blkObj.weights,'on')
                    pathItems{idxout}='Weights';
                else
                    pathItems{idxout}='';
                end
            end
        end
    end


