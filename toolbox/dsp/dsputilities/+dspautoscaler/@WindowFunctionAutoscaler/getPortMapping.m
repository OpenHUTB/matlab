function pathItems=getPortMapping(h,blkObj,inportNum,outportNum)%#ok





    numItemsRequested=length(outportNum);


    pathItems={};

    if(numItemsRequested>0)
        pathItems=cell(numItemsRequested,1);

        for idx=1:numItemsRequested
            switch outportNum(idx)
            case 1

                if strcmpi(blkObj.winmode,'Generate window')
                    pathItems{idx}='Window';
                else
                    pathItems{idx}='Output';
                end
            case 2


                pathItems{idx}='Window';
            otherwise

                pathItems{idx}='';
            end
        end
    end


