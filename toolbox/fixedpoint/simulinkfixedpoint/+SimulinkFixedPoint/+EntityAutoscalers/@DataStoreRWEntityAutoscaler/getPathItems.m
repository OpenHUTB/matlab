function pathItems=getPathItems(h,blkObj)%#ok








    numOfOutport=numel(blkObj.PortHandles.Outport);
    if numOfOutport>0
        for idx=1:numOfOutport
            pathItems{idx}=int2str(idx);%#ok-AGROW
        end
    else
        pathItems={'1'};
    end



