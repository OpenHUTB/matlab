function populateExternalOutputPort(hChannel,portName,portWidth,portDimension,TotalWidth,isComplex,portIdx,hElab)


    hChannel.ExtOutportNames{end+1}=sprintf('%s_%s',hChannel.ChannelPortLabel,portName);

    if nargin>7&&~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&hChannel.isFrameToSample


        if isComplex

            hChannel.ExtOutportWidths{end+1}=portWidth;
            hChannel.ExtOutportList.(portName).Width=portWidth;
            hChannel.ExtOutportDimensions{end+1}=2;
        else
            hChannel.ExtOutportWidths{end+1}=TotalWidth;
            hChannel.ExtOutportList.(portName).Width=TotalWidth;
            hChannel.ExtOutportDimensions{end+1}=1;
        end

    else

        if isComplex
            portDimension=2*portDimension;
        end


        if portDimension>1&&strcmp(hChannel.SamplePackingDimension,'All')
            hChannel.ExtOutportWidths{end+1}=portWidth;
            hChannel.ExtOutportList.(portName).Width=portWidth;
            hChannel.ExtOutportDimensions{end+1}=portDimension;

        else

            hChannel.ExtOutportWidths{end+1}=TotalWidth;
            hChannel.ExtOutportList.(portName).Width=TotalWidth;
            hChannel.ExtOutportDimensions{end+1}=1;
        end

    end

    hChannel.ExtOutportTotalWidth{end+1}=TotalWidth;
    hChannel.ExtOutportList.(portName).Index=portIdx;

end
