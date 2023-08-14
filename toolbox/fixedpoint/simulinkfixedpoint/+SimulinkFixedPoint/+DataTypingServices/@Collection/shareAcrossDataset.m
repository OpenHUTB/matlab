function[reqUpdateInGroupID,resultsToUpdateList]=shareAcrossDataset(this,topRunObj,result)



    uniqueID=result.UniqueIdentifier;
    crossBoundaryRec=result.getAutoscaler.gatherMdlRefBoundarySharedDT(uniqueID.getObject,uniqueID.getElementName);
    reqUpdateInGroupID=[];
    resultsToUpdateList=[];

    if~isempty(crossBoundaryRec)

        subMdl=bdroot(crossBoundaryRec.portInfo.blkObj.getFullName);


        subMdlApplicationData=SimulinkFixedPoint.getApplicationData(subMdl);


        runObj=subMdlApplicationData.dataset.getRun(this.proposalSettings.scaleUsingRunName);



        downstreamResult=runObj.getResult(crossBoundaryRec.portInfo.blkObj,crossBoundaryRec.portInfo.pathItem);



        upstreamResult=this.getSharedRecords({crossBoundaryRec.connectedBlkInfo},topRunObj);


        if isempty(upstreamResult)||isempty(downstreamResult)
            return;
        end

        runObj.dataTypeGroupInterface.addEdge(...
        upstreamResult.UniqueIdentifier.UniqueKey,...
        downstreamResult.UniqueIdentifier.UniqueKey);
    end
end
