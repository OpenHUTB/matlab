function associateRecords=gatherAssociatedParam(h,blkObj)








    associateRecords=[];

    ph=blkObj.PortHandles;

    [~,isBus]=hGetBusSignalHierarchy(h,ph.Inport(1));

    if isBus


        return;
    end

    [isValid,minVal,maxVal,pObj]=SimulinkFixedPoint.slfxpprivate(...
    'evalNumericParameterRange',blkObj,blkObj.InitialOutput);

    if isValid&&(~isempty(minVal)||~isempty(maxVal))&&...
        h.hIsICApplicable(blkObj)
        associateRecords.blkObj=blkObj;
        associateRecords.pathItem='1';
        associateRecords.srcInfo=[];
        associateRecords.ModelRequiredMin=minVal;
        associateRecords.ModelRequiredMax=maxVal;
        associateRecords.paramObj=pObj;
    end


