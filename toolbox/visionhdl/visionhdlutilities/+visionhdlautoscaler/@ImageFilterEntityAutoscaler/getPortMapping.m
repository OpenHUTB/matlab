function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)








    pathItems={};

    sizeOutportNum=length(outportNum);
    if sizeOutportNum>0
        pathItems=cell(sizeOutportNum,1);
        for idxout=1:sizeOutportNum
            if outportNum(idxout)==1
                pathItems{idxout}='dataOut';
            else
                pathItems{idxout}=num2str(idxout);
            end
        end
    end

end

