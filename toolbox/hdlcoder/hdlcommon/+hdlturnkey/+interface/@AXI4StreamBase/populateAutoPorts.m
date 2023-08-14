function populateAutoPorts(~,hN,hElab,hChannel)




    hChannel.AutoInportNames={};
    hChannel.AutoOutportNames={};
    hChannel.AutoInportWidths={};
    hChannel.AutoOutportWidths={};
    hChannel.AutoInportDimensions={};
    hChannel.AutoOutportDimensions={};
    hChannel.AutoTopInportSignals={};
    hChannel.AutoTopOutportSignals={};

    ufix1Type=pir_ufixpt_t(1,0);




    if(~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&...
        hChannel.isFrameToSample)
        return;
    end

    autoReadyName=hChannel.AutoReadyConnectionID;
    if hChannel.ChannelDirType==hdlturnkey.IOType.IN

        if hChannel.NeedAutoReadyWiring







            hChannel.AutoInportNames{end+1}=autoReadyName;
            hChannel.AutoInportWidths{end+1}=1;
            hChannel.AutoInportDimensions{end+1}=1;
            signalName=sprintf('%s_%s',autoReadyName,lower(hChannel.ChannelPortLabel));
            auto_ready=hN.addSignal(ufix1Type,signalName);
            hChannel.AutoTopInportSignals{end+1}=auto_ready;
            if hElab.isInternalSignalDefined(hChannel.AutoReadyConnectionID)
                hElab.connectSignalFrom(hChannel.AutoReadyConnectionID,auto_ready);
            else
                hElab.setInternalSignal(hChannel.AutoReadyConnectionID,auto_ready);
            end
        end

    else

        if hChannel.NeedAutoReadyWiring




            hChannel.AutoOutportNames{end+1}=autoReadyName;
            hChannel.AutoOutportWidths{end+1}=1;
            hChannel.AutoOutportDimensions{end+1}=1;
            signalName=sprintf('%s_%s',autoReadyName,lower(hChannel.ChannelPortLabel));
            auto_ready=hN.addSignal(ufix1Type,signalName);
            hChannel.AutoTopOutportSignals{end+1}=auto_ready;
            if hElab.isInternalSignalDefined(hChannel.AutoReadyConnectionID)
                hElab.connectSignalTo(hChannel.AutoReadyConnectionID,auto_ready);
            else
                hElab.setInternalSignal(hChannel.AutoReadyConnectionID,auto_ready);
            end
        end
    end

end