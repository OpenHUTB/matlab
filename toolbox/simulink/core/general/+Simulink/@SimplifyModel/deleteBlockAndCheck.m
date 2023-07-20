function[reductionOK,blocksNumRemoved,sopts,canRewire]=deleteBlockAndCheck(blocksList,FullPath,sopts,passThroughBlock,conditionFunction,blocksNumRemoved)

    [mdlName,subSysName]=Simulink.SimplifyModel.getSubsystemName(FullPath);
    topModel=sopts.topModel;
    load_system(mdlName);
    referringMdlrefBlks={};
    canRewire=0;

    if~isempty(subSysName)
        [connectedInBlock,srcPort]=Simulink.SimplifyModel.getSubsystemConnections(FullPath);
    elseif~strcmp(mdlName,topModel)
        connectedInBlock={};
        srcPort={};


        [~,mdlrefBlks]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

        for j=1:length(mdlrefBlks)
            referringModel=Simulink.SimplifyModel.getSubsystemName(mdlrefBlks{j});
            load_system(referringModel);
            if strcmp(get_param(mdlrefBlks{j},'ModelName'),mdlName)
                referringMdlrefBlks{end+1}=mdlrefBlks{j};%#ok<*AGROW>
                [connectedInBlock{end+1},srcPort{end+1}]=Simulink.SimplifyModel.getSubsystemConnections(referringMdlrefBlks{end});
            end
        end
    end


    for pp=1:length(blocksList)
        [srcList,dstList]=Simulink.SimplifyModel.getSrcDstList(blocksList{pp},true);
        if~isempty(srcList)&&~isempty(dstList)
            canRewire=true;
            if passThroughBlock
                for j=1:length(dstList)
                    try
                        add_line(FullPath,srcList(1),dstList(j));
                    catch E
                    end
                end
            end
        end
        delete_block(blocksList{pp});
    end

    if~isempty(subSysName)
        reconnectLines(FullPath,connectedInBlock,srcPort);
    elseif~strcmp(mdlName,topModel)
        for j=1:length(referringMdlrefBlks)
            referringModel=Simulink.SimplifyModel.getSubsystemName(referringMdlrefBlks{j});
            refMdlObj=get_param(referringModel,'Object');
            refMdlObj.refreshModelBlocks();
            reconnectLines(referringMdlrefBlks{j},connectedInBlock{j},srcPort{j});
        end
    end

    [reductionOK,blocksNumRemoved,sopts]=Simulink.SimplifyModel.checkCondition(mdlName,conditionFunction,sopts,blocksList,blocksNumRemoved,'Delete Block ');


    function reconnectLines(subSys,destList,srcList)
        portHandles=get_param(subSys,'Porthandles');

        if isempty(destList)||isempty(srcList)
            return;
        end
        portTypes=fields(destList);

        for k=1:length(portTypes)
            portHandle=portHandles.(portTypes{k});
            srcHandle=srcList.(portTypes{k});
            dstBlockHandle=destList.(portTypes{k});
            if~isempty(portHandle)
                for i=1:length(dstBlockHandle)
                    if~isempty(dstBlockHandle{i})&&~isempty(srcHandle{i})
                        portNum=1;
                        try
                            portNum=str2double(get_param(dstBlockHandle{i},'Port'));
                        catch E
                        end

                        for j=1:length(srcHandle{i})
                            try
                                add_line(get_param(subSys,'Parent'),portHandle(portNum),srcHandle{i}(j));
                                continue;
                            catch E %#ok<*NASGU>
                            end
                            try
                                add_line(get_param(subSys,'Parent'),srcHandle{i}(j),portHandle(portNum));
                            catch E
                            end
                        end
                    end
                end
            end
        end
