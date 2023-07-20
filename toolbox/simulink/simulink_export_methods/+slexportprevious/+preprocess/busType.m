function busType(obj)





    newRules={};
    verobj=obj.ver;

    if isR2010aOrEarlier(verobj)
        blocks=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'FollowLinks','off',...
        'Regexp','on',...
        'BlockType','(Inport|InportShadow|Outport|BusCreator)');
        if~isempty(blocks)

            newRules{end+1}=slexportprevious.rulefactory.removeInBlockType('OutDataTypeStr','BusCreator');
        end
        for i=1:length(blocks)
            block=blocks{i};
            outDataTypeStr=get_param(block,'OutDataTypeStr');
            busObjectName=getBusObjectName(outDataTypeStr);
            blockPattern=slexportprevious.rulefactory.identifyBlockBySID(block);
            blockType=get_param(block,'BlockType');
            if~strcmp(blockType,'BusCreator')&&~isempty(busObjectName)
                removeOutDataTypeStr=['<Block',blockPattern,slexportprevious.rulefactory.remove('OutDataTypeStr'),'>'];
            else
                removeOutDataTypeStr='';
            end
            if~isempty(busObjectName)

                addUseBusObject=slexportprevious.rulefactory.addParameterToBlock(...
                blockPattern,'UseBusObject','on');
                if strcmp(busObjectName,'BusObject')

                    addBusObject='';
                else
                    addBusObject=slexportprevious.rulefactory.addParameterToBlock(...
                    blockPattern,'BusObject',busObjectName);
                end
            else
                addUseBusObject='';
                addBusObject='';
            end
            if~isempty(addUseBusObject)||...
                ~isempty(addBusObject)||...
                ~isempty(removeOutDataTypeStr)

                newRules{end+1}=[addUseBusObject,addBusObject,removeOutDataTypeStr];%#ok
            end
        end
    end

    obj.appendRules(newRules);

end

function busObjectName=getBusObjectName(dataTypeStr)

    dataTypeStr=strtrim(dataTypeStr);
    busHeader='Bus:';
    busHeaderLen=length(busHeader);

    if~strncmp(dataTypeStr,busHeader,busHeaderLen)

        busObjectName='';
    else
        busObjectName=dataTypeStr(busHeaderLen+1:end);
        busObjectName=strtrim(busObjectName);
    end
end
