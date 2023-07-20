function pathItems=getPathItems(h,blkObj)%#ok








    clz=class(blkObj);

    switch clz
    case 'Simulink.BusSelector'
        numOfOutport=numel(blkObj.PortHandles.Outport);
        for idx=1:numOfOutport
            pathItems{idx}=int2str(idx);%#ok
        end
    otherwise
        pathItems={'1'};
    end


