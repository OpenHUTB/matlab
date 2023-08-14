function sharedLists=gatherSharedDT(h,blkObj)







    sharedLists={};
    hPorts=blkObj.PortHandles;
    inportObj=get_param(hPorts.Inport(1),'Object');

    [srcBlkAtInport,srcSigAtInport,srcInfo]=...
    h.getSourceSignal(inportObj);

    if(~(isempty(srcBlkAtInport)||isempty(srcSigAtInport)))&&(~strcmp(blkObj.fcn,'Index'))






        recordForInport.blkObj=srcBlkAtInport;
        recordForInport.pathItem=srcSigAtInport;
        recordForInport.srcInfo=srcInfo;

        recordForOutport.blkObj=blkObj;
        recordForOutport.pathItem='1';

        sharedLists=cell(1,2);
        sharedLists{1}=recordForInport;
        sharedLists{2}=recordForOutport;
        sharedLists={sharedLists};
    end


