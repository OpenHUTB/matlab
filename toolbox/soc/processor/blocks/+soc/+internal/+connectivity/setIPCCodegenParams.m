function setIPCCodegenParams(mdlName)







    ipcChBlks=find_system(mdlName,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','FollowLinks','on','MaskType','Interprocess Data Channel');
    if isempty(ipcChBlks)
        return;
    end
    out=soc.internal.connectivity.findIPCBlocks(ipcChBlks);
    origDirtyFlagTopMdl=get_param(mdlName,'Dirty');

    CPU1CPU2ChannelNum=0;
    CPU1CMChannelNum=0;
    CPU2CMChannelNum=0;
    CPU1CLAChannelNum=0;
    CPU2CLAChannelNum=0;
    for i=1:numel(out)
        dstRefName=strrep(regexp(out{i}.ipcread,'^.*?\/','match'),'/','');
        dstRefName=dstRefName{1};
        origDirtyFlagReadMdl=get_param(dstRefName,'Dirty');
        srcRefName=strrep(regexp(out{i}.ipcwrite,'^.*?\/','match'),'/','');
        srcRefName=srcRefName{1};
        origDirtyFlagWriteMdl=get_param(srcRefName,'Dirty');

        val=get_param(out{i}.ipcchannel,'showEventPort');
        NumBuff=get_param(out{i}.ipcchannel,'NumBuffers');

        setIPCProcUnitParams(dstRefName,out{i}.ipcread,srcRefName,out{i}.ipcwrite);


        if(matches(get_param(out{i}.ipcread,'IPCBetween'),'0'))
            ChannelNum=CPU1CPU2ChannelNum;
            CPU1CPU2ChannelNum=CPU1CPU2ChannelNum+1;
        elseif(matches(get_param(out{i}.ipcread,'IPCBetween'),'1'))
            ChannelNum=CPU1CMChannelNum;
            CPU1CMChannelNum=CPU1CMChannelNum+1;
        elseif(matches(get_param(out{i}.ipcread,'IPCBetween'),'2'))
            ChannelNum=CPU2CMChannelNum;
            CPU2CMChannelNum=CPU2CMChannelNum+1;
        elseif(matches(get_param(out{i}.ipcread,'IPCBetween'),'3'))
            ChannelNum=CPU1CLAChannelNum;
            CPU1CLAChannelNum=CPU1CLAChannelNum+1;
        elseif(matches(get_param(out{i}.ipcread,'IPCBetween'),'4'))
            ChannelNum=CPU2CLAChannelNum;
            CPU2CLAChannelNum=CPU2CLAChannelNum+1;
        end

        set_param(out{i}.ipcread,...
        'ChannelNum',num2str(ChannelNum),...
        'IsIntEnabled',num2str(isequal(val,'on')),...
        'NumBuffers',NumBuff);
        set_param(out{i}.ipcwrite,...
        'ChannelNum',num2str(ChannelNum),...
        'IsIntEnabled',num2str(isequal(val,'on')),...
        'NumBuff',NumBuff,...
        'DataType',get_param(out{i}.ipcread,'DataType'));

        toggleSDILogging(out{i});

        set_param(dstRefName,'Dirty',origDirtyFlagReadMdl);
        set_param(srcRefName,'Dirty',origDirtyFlagWriteMdl);
    end
    set_param(mdlName,'Dirty',origDirtyFlagTopMdl);
end


function toggleSDILogging(IPCBlocks)


    writeDriverBlk=[IPCBlocks.ipcwrite,'/Variant/CODEGEN/IPC Write'];
    ph=get_param(writeDriverBlk,'PortHandles');




    overwritesLine=get_param(ph.Outport(1),'Line');
    numBuffUsedLine=get_param(ph.Outport(2),'Line');
    if(matches(get_param(IPCBlocks.ipcchannel,'ShowBufferOverwritten'),'on'))
        set_param(ph.Outport(1),'DataLogging','on')
        set_param(overwritesLine,'Name',[get_param(IPCBlocks.ipcchannel,'Name'),': Number of overwrites'])
    else
        set_param(ph.Outport(1),'DataLogging','off')
    end
    if(matches(get_param(IPCBlocks.ipcchannel,'ShowNumUsedBuffers'),'on'))
        set_param(ph.Outport(2),'DataLogging','on')
        set_param(numBuffUsedLine,'Name',[get_param(IPCBlocks.ipcchannel,'Name'),': Number of buffers used'])
    else
        set_param(ph.Outport(2),'DataLogging','off')
    end
end


function setIPCProcUnitParams(dstRef,dstBlk,srcRef,srcBlk)


    dstCore=codertarget.targethardware.getProcessingUnitName(dstRef);
    srcCore=codertarget.targethardware.getProcessingUnitName(srcRef);







    set_param(dstBlk,'CurrentPU',dstCore);
    set_param(srcBlk,'CurrentPU',srcCore);
    switch(dstCore)
    case 'c28xCPU1'
        set_param(dstBlk,'CurrentPU','0');
    case 'c28xCPU2'
        set_param(dstBlk,'CurrentPU','1');
    case 'ArmCPU3'
        set_param(dstBlk,'CurrentPU','2');
    case 'CPU1CLA1'
        set_param(dstBlk,'CurrentPU','3');
    case 'CPU2CLA1'
        set_param(dstBlk,'CurrentPU','4');
    end
    switch(srcCore)
    case 'c28xCPU1'
        set_param(srcBlk,'CurrentPU','0');
    case 'c28xCPU2'
        set_param(srcBlk,'CurrentPU','1');
    case 'ArmCPU3'
        set_param(srcBlk,'CurrentPU','2');
    case 'CPU1CLA1'
        set_param(srcBlk,'CurrentPU','3');
    case 'CPU2CLA1'
        set_param(srcBlk,'CurrentPU','4');
    end







    if((matches(dstCore,'c28xCPU1')&&matches(srcCore,'c28xCPU2'))...
        ||(matches(dstCore,'c28xCPU2')&&matches(srcCore,'c28xCPU1')))
        set_param(dstBlk,'IPCBetween','0');
        set_param(srcBlk,'IPCBetween','0');
    elseif((matches(dstCore,'c28xCPU1')&&matches(srcCore,'ArmCPU3'))...
        ||(matches(dstCore,'ArmCPU3')&&matches(srcCore,'c28xCPU1')))
        set_param(dstBlk,'IPCBetween','1');
        set_param(srcBlk,'IPCBetween','1');
    elseif((matches(dstCore,'c28xCPU2')&&matches(srcCore,'ArmCPU3'))...
        ||(matches(dstCore,'ArmCPU3')&&matches(srcCore,'c28xCPU2')))
        set_param(dstBlk,'IPCBetween','2');
        set_param(srcBlk,'IPCBetween','2');
    elseif((matches(dstCore,'CPU1CLA1')&&matches(srcCore,'c28xCPU1'))...
        ||(matches(dstCore,'c28xCPU1')&&matches(srcCore,'CPU1CLA1')))
        set_param(dstBlk,'IPCBetween','3');
        set_param(srcBlk,'IPCBetween','3');
    elseif((matches(dstCore,'CPU2CLA1')&&matches(srcCore,'c28xCPU2'))...
        ||(matches(dstCore,'c28xCPU2')&&matches(srcCore,'CPU2CLA1')))
        set_param(dstBlk,'IPCBetween','4');
        set_param(srcBlk,'IPCBetween','4');
    end
end
