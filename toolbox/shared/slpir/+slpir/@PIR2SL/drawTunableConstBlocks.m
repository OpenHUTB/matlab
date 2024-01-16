function drawTunableConstBlocks(tunablePorts,DUTName,subsystemOnDUT)

    if~isempty(tunablePorts)

        portsOnDUT=keys(tunablePorts);
        posOfDUT=get_param([subsystemOnDUT,'/',DUTName],'Position');

        constBlkSize=[30,30];
        moveDown=[0,50];
        posOfBlk=[posOfDUT(1)-60,posOfDUT(2)-30];

        for ii=1:numel(portsOnDUT)

            portName=char(portsOnDUT(ii));

            portInfo=tunablePorts(portName);
            constBlkName=[subsystemOnDUT,'/','tunable_const'];
            constBlkHandle=add_block('built-in/Constant',constBlkName,'MakeNameUnique','on','Value',portName);

            if isSLEnumType(portInfo.dataType.viadialog)
                set_param(constBlkHandle,'OutDataTypeStr',['Enum: ',portInfo.dataType.viadialog]);
            else
                set_param(constBlkHandle,'OutDataTypeStr',portInfo.dataType.viadialog);
            end

            posOfBlk=posOfBlk+moveDown;
            set_param(constBlkHandle,'Position',[posOfBlk,posOfBlk+constBlkSize]);
            srcPort=[get_param(constBlkHandle,'Name'),'/','1'];
            dstPort=[DUTName,'/',get_param(portInfo.SLPortHandle,'Port')];
            add_line(subsystemOnDUT,srcPort,dstPort,'autorouting','on');
        end
    end


