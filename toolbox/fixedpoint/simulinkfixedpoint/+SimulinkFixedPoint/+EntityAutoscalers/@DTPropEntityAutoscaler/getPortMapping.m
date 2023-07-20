function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok  





    sizeInportNum=length(inportNum);

    if sizeInportNum==0

        pathItems={};
        return;
    end

    pathItems=cell(sizeInportNum,1);

    for idxin=1:sizeInportNum

        switch inportNum(idxin)
        case 1
            pathItems{idxin}='Ref1';
        case 2
            pathItems{idxin}='Ref2';
        case 3
            pathItems{idxin}='Prop';
        end
    end

