function sharedLists=gatherSharedDT(h,blkObj)




    sharedLists={};
    [isResolved,sigRecResolved]=h.getResolvedSLSignal(blkObj);

    sfdataRec.blkObj=blkObj;
    sfdataRec.pathItem=blkObj.name;

    chartId=sf('DataChartParent',blkObj.Id);
    parentH=sfprivate('chart2block',chartId);

    if isResolved


        signalObject=sigRecResolved.object;
        signalObjectName=sigRecResolved.name;
        sigRec.blkObj=SimulinkFixedPoint.SignalObjectWrapperCreator.getWrapper(...
        signalObject,signalObjectName,get_param(bdroot(parentH),'Name'));
        sigRec.pathItem=signalObjectName;

        sharedLists{1}={sigRec,sfdataRec};
    elseif strcmp(blkObj.Scope,'Data Store Memory')
        DSMBlockHandle=slprivate('getDataStoreHandle',blkObj);






        if DSMBlockHandle~=-1&&...
            ~Stateflow.SLUtils.isChildOfStateflowBlock(DSMBlockHandle)
            dsmRec.blkObj=get_param(DSMBlockHandle,'Object');
            dsmRec.pathItem='1';
            sharedLists{1}={dsmRec,sfdataRec};
        end
    end

    inportH=getPortHandleForData(blkObj,parentH);
    if~isempty(inportH)&&hIsVirtualBus(h,inportH)
        portObj=get_param(inportH,'Object');
        sharedDTatOnePort=getAllSourceSignal(h,portObj,false);
        sharedLists=h.hAppendToSharedLists(sharedLists,sharedDTatOnePort);
    end


    function inportH=getPortHandleForData(d,chartH)
        inportH=[];


        if~strcmp(d.Scope,'Input')
            return;
        end


        parentObj=d.getParent;
        if isempty(sf('find',parentObj.Id,'.isa','chart'))
            return;
        end


        rootObject=get_param(bdroot(chartH),'Object');
        if(rootObject.isLibrary)
            return;
        end

        sfunH=Stateflow.SLUtils.findSystem(chartH,'BlockType','S-Function');
        portHandles=get_param(sfunH,'PortHandles');
        portNum=d.Port;
        inportH=portHandles.Inport(portNum);




