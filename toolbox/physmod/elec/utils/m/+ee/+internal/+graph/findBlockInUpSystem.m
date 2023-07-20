function physicalBlockList=findBlockInUpSystem(PMIOPort)






    subSystem=get_param(PMIOPort,'Parent');
    f=Simulink.FindOptions('SearchDepth',1);

    if Simulink.internal.useFindSystemVariantsMatchFilter()





        f.MatchFilter=@Simulink.match.activeVariants;
    else



        f.Variants='ActiveVariants';
    end

    PMIOPorts=getfullname(Simulink.findBlocksOfType(subSystem,'PMIOPort',f));
    if ischar(PMIOPorts)
        PMIOPorts={PMIOPorts};
    end


    idxLeft=0;
    idxRight=0;
    for idx=1:numel(PMIOPorts)
        side=get_param(PMIOPorts{idx},'Side');
        portNumber=str2double(get_param(PMIOPorts{idx},'Port'));
        if strcmp(side,'Left')
            idxLeft=idxLeft+1;
            PMIOPortsTableLeft(idxLeft,1)={portNumber};
            PMIOPortsTableLeft(idxLeft,2)={get_param(PMIOPorts{idx},'Handle')};
        else
            idxRight=idxRight+1;
            PMIOPortsTableRight(idxRight,1)={portNumber};
            PMIOPortsTableRight(idxRight,2)={get_param(PMIOPorts{idx},'Handle')};
        end
    end


    Port=get_param(PMIOPort,'Port');
    Side=get_param(PMIOPort,'Side');


    warnId='Simulink:modelReference:ParameterOnlyValidWhenModelIsCompiledAndTopModel';
    w=warning('query',warnId);
    warning('off',warnId)
    if~ismember('PortConnectivity',fields(get(get_param(subSystem,'Object'))))
        warning(w.state,warnId)
        physicalBlockList=[];
        return
    end
    warning(w.state,warnId)

    structBlock=get_param(subSystem,'PortConnectivity');

    if strcmp(Side,'Left')
        idxPort=find(str2double(Port)==[PMIOPortsTableLeft{:,1}]);
        portType=strcat('LConn',int2str(idxPort));
        for idx=1:numel(structBlock)
            if strcmp(structBlock(idx).Type,portType)
                blockHandles=structBlock(idx).DstBlock;
                break;
            end
        end
    end

    if strcmp(Side,'Right')
        idxPort=find(str2double(Port)==[PMIOPortsTableRight{:,1}]);
        portType=strcat('RConn',int2str(idxPort));
        for idx=1:numel(structBlock)
            if strcmp(structBlock(idx).Type,portType)
                blockHandles=structBlock(idx).DstBlock;
                break;
            end
        end
    end

    blockList=[];
    for idxBlock=1:numel(blockHandles)
        thisBlockHandle=blockHandles(idxBlock);
        thisBlock={getfullname(thisBlockHandle)};
        blockList=[blockList;thisBlock];
    end


    physicalBlockList=ee.internal.graph.tracePhysicalBlocks(get_param(PMIOPort,'Parent'),blockList);

end
