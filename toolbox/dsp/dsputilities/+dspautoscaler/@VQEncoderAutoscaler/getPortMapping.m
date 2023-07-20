function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok




    numItemsRequested=length(outportNum);


    pathItems={};

    if(numItemsRequested>0)
        pathItems=cell(numItemsRequested,1);
        hasCodewordOutport=strcmp(blkObj.outQU,'on');

        for idx=1:numItemsRequested
            switch outportNum(idx)
            case 1


                pathItems{idx}='Output';

            case 2


                if hasCodewordOutport

                    pathItems{idx}='Output Q(U)';
                else

                    pathItems{idx}='Output D(QERR)';
                end

            case 3



                pathItems{idx}='Output D(QERR)';

            otherwise

                pathItems{idx}='';
            end
        end
    end
