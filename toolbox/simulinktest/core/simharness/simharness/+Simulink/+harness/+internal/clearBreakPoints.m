function clearBreakPoints(modelName,ssBlk)
    import Simulink.Debug.*;


    if~(strcmpi(get_param(ssBlk,'BlockType'),'SubSystem'))
        return;
    end


    ssPath=[get_param(ssBlk,'Parent'),'/',get_param(ssBlk,'name')];



    try
        itemList=BreakpointList.getAllBreakpoints();
        for i=1:numel(itemList)
            item=itemList{i};
            if item.domain==BaseItemDomainEnum.Stateflow&&item.belongsToModel(modelName)
                if ishandle(item.ownerUdd)&&~isempty(strfind(item.ownerUdd.Path,ssPath))

                    BreakpointList.removeBreakpointFromList(item);
                end
            end
        end

        itemList=WatchpointList.getAllWatchpoints();
        for i=1:numel(itemList)
            item=itemList{i};
            if item.domain==BaseItemDomainEnum.Stateflow&&item.belongsToModel(modelName)
                if ishandle(item.dataUdd)&&~isempty(strfind(item.dataUdd.Path,ssPath))

                    BreakpointList.removeBreakpointFromList(item);
                end
            end
        end
    catch ME
        Simulink.harness.internal.warn(ME);
    end
