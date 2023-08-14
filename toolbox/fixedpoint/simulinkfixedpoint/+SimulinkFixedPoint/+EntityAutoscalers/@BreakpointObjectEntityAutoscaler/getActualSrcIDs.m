function actualSrcIDs=getActualSrcIDs(~,blkObj)




    actualSrcIDs={};


    parser=SimulinkFixedPoint.SimulinkVariableUsageParser.getParserForDataObjects();

    validUsers=getValidUsers(parser,...
    blkObj.ContextName,...
    blkObj.Name,...
    'SearchMethod','cached');
    if~isempty(validUsers)
        dataHandler=fxptds.SimulinkDataArrayHandler;
        for ii=1:numel(validUsers)

            uniqueID=dataHandler.getUniqueIdentifier(struct('Object',validUsers{ii},'ElementName','1'));
            actualSrcIDs=[actualSrcIDs,{uniqueID}];%#ok<AGROW>
        end
    end
end


