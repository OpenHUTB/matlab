function actualSrcIDs=getActualSrcIDs(~,blkObj)




    actualSrcIDs={};


    parser=SimulinkFixedPoint.SimulinkVariableUsageParser.getParserForDataObjects();

    validUsers=getValidUsers(parser,...
    blkObj.ContextName,...
    blkObj.Name,...
    'SearchMethod','cached');

    if~isempty(validUsers)
        dataHandler=fxptds.SimulinkDataArrayHandler;
        entityAutoscalerInterface=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
        for ii=1:numel(validUsers)



            sourceBlock=validUsers{ii};
            blockAutoscaler=entityAutoscalerInterface.getAutoscaler(sourceBlock);
            outputPathItem=blockAutoscaler.getPortMapping(sourceBlock,[],1);
            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',sourceBlock,'ElementName',outputPathItem));
            actualSrcIDs=[actualSrcIDs,{uniqueID}];%#ok<AGROW>
        end
    end
end