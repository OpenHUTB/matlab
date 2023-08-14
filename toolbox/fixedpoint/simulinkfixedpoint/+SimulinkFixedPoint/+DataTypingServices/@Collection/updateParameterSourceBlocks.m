function srcIDs=updateParameterSourceBlocks(~,varUsage,result,runObj)




    numbOfUsers=length(varUsage.Users);
    srcIDs={};
    if numbOfUsers>0
        eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
        for userIdx=1:numbOfUsers
            srcBlkObj=varUsage.Users{userIdx};
            blkEA=eai.getAutoscaler(srcBlkObj);
            pathItems=blkEA.getPathItems(srcBlkObj);

            if~isempty(pathItems)
                dstruct=struct('Object',srcBlkObj,'ElementName',pathItems{1});
            else
                dstruct=struct('Object',srcBlkObj);
            end
            dHandler=fxptds.SimulinkDataArrayHandler;
            srcID=dHandler.getUniqueIdentifier(dstruct);
            if~isempty(srcID)
                srcIDs{end+1}=srcID;%#ok<AGROW>
            end
        end
        if~isempty(srcIDs)
            result.setActualSourceIDs(srcIDs);
            SimulinkFixedPoint.Autoscaler.addToSrcList(runObj,result,srcIDs);
        end

    end
end
