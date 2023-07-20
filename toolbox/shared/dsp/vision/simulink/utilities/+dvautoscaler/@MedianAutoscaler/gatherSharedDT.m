function sharedLists=gatherSharedDT(h,blkObj)







    sharedLists={};
    hPorts=blkObj.PortHandles;
    inportObj=get_param(hPorts.Inport(1),'Object');

    [srcBlkAtInport,srcSigAtInport,srcInfo]=...
    h.getSourceSignal(inportObj);

    if~(isempty(srcBlkAtInport)||isempty(srcSigAtInport))&&...
        ((strcmp(blkObj.outputDataTypeStr,'Inherit: Same as accumulator')&&strcmp(blkObj.accumDataTypeStr,'Inherit: Same as product output')&&...
        strcmp(blkObj.prodOutputDataTypeStr,'Inherit: Same as input'))||...
        (strcmp(blkObj.outputDataTypeStr,'Inherit: Same as accumulator')&&strcmp(blkObj.accumDataTypeStr,'Inherit: Same as input'))||...
        (strcmp(blkObj.outputDataTypeStr,'Inherit: Same as product output')&&strcmp(blkObj.prodOutputDataTypeStr,'Inherit: Same as input'))||...
        (strcmp(blkObj.outputDataTypeStr,'Inherit: Same as input')))





        recordForInport.blkObj=srcBlkAtInport;
        recordForInport.pathItem=srcSigAtInport;
        recordForInport.srcInfo=srcInfo;

        recordForOutport.blkObj=blkObj;
        recordForOutport.pathItem='Output';

        sharedLists=cell(1,2);
        sharedLists{1}=recordForInport;
        sharedLists{2}=recordForOutport;
        sharedLists={sharedLists};

    end


