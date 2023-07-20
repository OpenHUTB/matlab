
















function populatePortsToAddBusHierSSOrSigSpec(optArgs,srcPort,dstPorts,attributeStructVec,isDstAttrib,isLib,isBusCase,origBlkCell)

    narginchk(5,8);
    if nargin==5
        isLib=false;
        isBusCase=false;
        origBlkCell={};
    end

    if isDstAttrib
        isDstAttrib=true;
    else
        isDstAttrib=false;
    end


    if isDstAttrib
        portParent=i_replaceCarriageReturnWithSpace(get(dstPorts,'Parent'));
        attributeStruct=getPortAttributeStruct(portParent,dstPorts,attributeStructVec);


        setSignalNameOnGroundBlock(srcPort,attributeStruct,isBusCase);
    else
        portParent=i_replaceCarriageReturnWithSpace(get(srcPort,'Parent'));
        attributeStruct=getPortAttributeStruct(portParent,srcPort,attributeStructVec);
    end



    if isempty(attributeStruct)


        return;
    end

    if isBusCase&&~isempty(attributeStruct.CompiledBusType)&&~strcmp('NOT_BUS',attributeStruct.CompiledBusType)
        Simulink.variant.reducer.utils.assert(isDstAttrib,'Only called for input port case')
        portBusSubsystemStruct=Simulink.variant.reducer.types.VRedPortBusSubsystem;
        portBusSubsystemStruct.SrcPort=srcPort;
        portBusSubsystemStruct.DstPort=dstPorts;
        portBusSubsystemStruct.CompiledBusType=attributeStruct.CompiledBusType;
        portBusSubsystemStruct.CompiledBusStruct=attributeStruct.CompiledBusStruct;
        portBusSubsystemStruct.CompiledSignalHierarchy=attributeStruct.CompiledSignalHierarchy;
        portBusSubsystemStruct.OrigBlkCell=origBlkCell;

        if isempty(optArgs.PortsToAddBusSubsystemBlock)
            optArgs.PortsToAddBusSubsystemBlock=portBusSubsystemStruct;
        else
            optArgs.PortsToAddBusSubsystemBlock(end+1)=portBusSubsystemStruct;
        end
        return;
    end

    if isLib||~optArgs.getOptions().ValidateSignals
        return;
    end


    if~strcmp('NOT_BUS',attributeStruct.CompiledBusType)
        return;
    end

    ssPortInfo=Simulink.variant.reducer.types.VRedPortInfo;
    ssPortInfo.SrcPortHandle=srcPort;
    ssPortInfo.DstPortHandle=dstPorts;
    ssPortInfo.PortAttributes=attributeStruct;

    ssPortBlockInfo.ssPortInfo=ssPortInfo;
    ssPortBlockInfo.portParent=portParent;
    optArgs.setPortsToAddSigSpec(ssPortBlockInfo.portParent,ssPortBlockInfo.ssPortInfo);
end



function attrStruct=getPortAttributeStruct(blk,pH,compPortAttrStructsVec)






    if isempty(compPortAttrStructsVec)
        attrStruct=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct(false);
        return;
    end

    attrStruct=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct();

    try

        blkPortH=get_param(blk,'PortHandles');
        blkType=get_param(blk,'BlockType');


        portBlkIdx=[blkPortH.Inport,blkPortH.Outport]==pH;




        isSubsystem=strcmp(blkType,'SubSystem');
        isNonProtectedModel=strcmp(blkType,'ModelReference')&&strcmp(get_param(blk,'ProtectedModel'),'off');
        isSubsystemResolved=isSubsystem&&strcmp(get_param(blk,'StaticLinkStatus'),'resolved');


        if isSubsystem&&~isSubsystemResolved
            portBlocks=get_param(find_system(blk,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.allVariants,...
            'SearchDepth',1,...
            'regexp','on',...
            'BlockType','Inport|Outport'),'Name');
            portBlk=portBlocks{portBlkIdx};
            idx=Simulink.variant.reducer.utils.searchNameInCell(portBlk,{compPortAttrStructsVec.PortBlockName});
            Simulink.variant.reducer.utils.assert(~isempty(idx));
            attrStruct=compPortAttrStructsVec(idx);

        elseif isNonProtectedModel||isSubsystemResolved
            graphPortBlkNames={compPortAttrStructsVec.PortBlockName};
            portBlk=graphPortBlkNames{portBlkIdx};
            if isNonProtectedModel
                graph=get_param(blk,'ModelName');
            else
                graph=blk;
            end
            portBlocks=get_param(find_system(graph,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'SearchDepth',1,...
            'regexp','on',...
            'BlockType','Inport|Outport'),'Name');
            idx=Simulink.variant.reducer.utils.searchNameInCell(portBlk,portBlocks);
            if isempty(idx),return;end
            attrStruct=compPortAttrStructsVec(portBlkIdx);

        else
            attrStruct=compPortAttrStructsVec(portBlkIdx);
        end
    catch ex %#ok<NASGU>
    end
end

function setSignalNameOnGroundBlock(srcPort,attributeStruct,isBusCase)

    if~isBusCase
        return;
    end

    try
        set(srcPort,'Name',attributeStruct.CompiledSignalHierarchy.SignalName);
    catch ex %#ok<NASGU>
    end

end


