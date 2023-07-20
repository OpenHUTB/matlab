function actualSrcBlkObj=getActualSrcBlkObj(h,blkObj)




    actualSrcBlkObj={};

    inportHandles=blkObj.PortHandles.Inport;

    for i=1:length(inportHandles)
        portObj=get_param(inportHandles(i),'Object');
        srcBlkObj=h.getSourceSignal(portObj);
        if~isempty(srcBlkObj)
            actualSrcBlkObj{end+1}=srcBlkObj;%#ok<AGROW>
        end
    end


