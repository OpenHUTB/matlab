function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok  





    sizeInportNum=length(inportNum);
    sizeOutportNum=length(outportNum);
    totalPortNum=sizeInportNum+sizeOutportNum;

    if totalPortNum==0

        pathItems={};
        return;
    end

    pathItems=cell(sizeInportNum+sizeOutportNum,1);

    for idxin=1:sizeInportNum

        pathItems{idxin}=['Input',int2str(inportNum(idxin))];
    end

    for idxout=1:sizeOutportNum
        pathItems{sizeInportNum+idxout}=int2str(outportNum(idxout));
    end

