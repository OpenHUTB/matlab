function actualSrcBlkObj=getActualSrcBlkObj(h,blkObj)





    actualSrcBlkObjSet=containers.Map;



    if isa(blkObj,'Simulink.Inport')&&...
        ~isa(get_param(blkObj.Parent,'Object'),'Simulink.BlockDiagram')
        sourceBlkObj=h.getSourceSignal(blkObj);
        if~isempty(sourceBlkObj)
            actualSrcBlkObjSet(sourceBlkObj.getFullName)=sourceBlkObj;
        end
    end

    inportHandles=blkObj.PortHandles.Inport;

    for i=1:length(inportHandles)
        portObj=get_param(inportHandles(i),'Object');
        srcBlkObj=h.getSourceSignal(portObj);
        if~isempty(srcBlkObj)
            actualSrcBlkObjSet(srcBlkObj.getFullName)=srcBlkObj;
        end
    end

    actualSrcBlkObj=actualSrcBlkObjSet.values;

