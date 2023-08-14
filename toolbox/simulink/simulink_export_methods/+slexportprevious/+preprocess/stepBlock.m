function stepBlock(obj)




    blkType='Step';

    if isR2019bOrEarlier(obj.ver)
        Stepblocks=slexportprevious.utils.findBlockType(obj.modelName,blkType);
        if(~isempty(Stepblocks))

            for i=1:length(Stepblocks)
                blk=Stepblocks{i};

                if~strcmp(get_param(blk,'OutDataTypeStr'),'double')
                    add_DTC_block(blk);
                end
            end
        end
    end

end


function delete_lines(blkHandle,portType)


    portHdlStruct=get_param(blkHandle,'PortHandles');
    portLinesToDelete=get_param(portHdlStruct.(portType),'Line');

    if~iscell(portLinesToDelete)
        portLinesToDelete={portLinesToDelete};
    end

    for i=1:length(portLinesToDelete)
        delete_line(portLinesToDelete{i});
    end

end




function connectSrcBlkToDestBlk(srcBlkHandle,srcPortIdx,destBlockHandle,destPortIdx,parentLocation)


    destPortHandles=get_param(destBlockHandle,'Porthandles');
    destInputPortHandles=destPortHandles.Inport;

    srcBlkPortHandles=get_param(srcBlkHandle,'Porthandles');
    srcBlkOutputPortHandles=srcBlkPortHandles.Outport;

    for portIdx=1:numel(srcPortIdx)
        add_line(parentLocation,srcBlkOutputPortHandles(srcPortIdx(portIdx)),destInputPortHandles(destPortIdx(portIdx)),'autorouting','on');
    end

end






function add_DTC_block(blk)

    positionBlk=get_param(blk,'Position');
    parentLocationBlk=get_param(blk,'Parent');
    nameBlk=get_param(blk,'Name');
    handleBlk=get_param(blk,'Handle');


    portConnectivityBlk=get_param(blk,'PortConnectivity');


    dstBlkHandle=portConnectivityBlk.DstBlock;
    dstPortNumber=portConnectivityBlk.DstPort;


    delete_lines(blk,'Outport');



    blkPath=strfind(blk,'/');
    dtcBlkHandle=add_block('simulink/Signal Attributes/Data Type Conversion',[blk(1:blkPath(end)),nameBlk,'''s DTC'],'position',positionBlk,'MakeNameUnique','on');

    set_param(dtcBlkHandle,'OutDataTypeStr',get_param(blk,'OutDataTypeStr'));




    connectSrcBlkToDestBlk(handleBlk,1,dtcBlkHandle,1,parentLocationBlk);


    for dstBlockIndex=1:numel(dstBlkHandle)
        connectSrcBlkToDestBlk(dtcBlkHandle,1,dstBlkHandle(dstBlockIndex),(dstPortNumber(dstBlockIndex)+1),parentLocationBlk);
    end

end








function add_DTC_block_keep_position(blk)

    positionBlk=get_param(blk,'Position');
    parentLocationBlk=get_param(blk,'Parent');
    nameBlk=get_param(blk,'Name');
    handleBlk=get_param(blk,'Handle');



    lines=find_system(parentLocationBlk,'MatchFilter',@Simulink.match.allVariants,'findall','on','type','line','SrcBlockHandle',handleBlk);
    line_positions=get_param(lines,'Points');


    delete_lines(blk,'Outport');



    blkPath=strfind(blk,'/');
    dtcBlkHandle=add_block('simulink/Signal Attributes/Data Type Conversion',[blk(1:blkPath(end)),nameBlk,'''s DTC'],'position',positionBlk,'MakeNameUnique','on');

    set_param(dtcBlkHandle,'OutDataTypeStr',get_param(blk,'OutDataTypeStr'));




    connectSrcBlkToDestBlk(handleBlk,1,dtcBlkHandle,1,parentLocationBlk);



    add_line(parentLocationBlk,line_positions);
end
























