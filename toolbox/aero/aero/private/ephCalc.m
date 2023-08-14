function[p,buf1,buf2]=ephCalc(cal,obj1,obj2,buf1,buf2,t,ephConstants,ind,velFlag,registerNumber,loadFlag)































    if loadFlag
        if isempty(obj1)
            if velFlag
                p=zeros(3,2);
            else
                p=zeros(3,1);
            end
            return
        else
            buf1=obj1.ephData(1:end,registerNumber);
        end
        if isempty(obj2)
            buf2=[];
        else
            buf2=obj2.ephData(1:end,registerNumber);
        end
    end


    switch cal
    case 'Planet'
        p=ephInterp(buf1,t,ephConstants.POINTERS(2,ind),3,ephConstants.POINTERS(3,ind),velFlag);
    case 'Earth'
        p=ephInterp(buf1,t,ephConstants.POINTERS(2,ind),3,ephConstants.POINTERS(3,ind),velFlag)-...
        ephInterp(buf2,t,ephConstants.POINTERS(2,10),3,ephConstants.POINTERS(3,10),velFlag)./...
        (1+ephConstants.EMRAT);
    case 'Moon'
        pmoon=ephInterp(buf1,t,ephConstants.POINTERS(2,ind),3,ephConstants.POINTERS(3,ind),velFlag);
        p=ephInterp(buf2,t,ephConstants.POINTERS(2,3),3,ephConstants.POINTERS(3,3),velFlag)...
        -pmoon./(1+ephConstants.EMRAT)+pmoon;
    case 'Solar'
        if velFlag
            p=zeros(3,2);
        else
            p=zeros(3,1);
        end
    end

