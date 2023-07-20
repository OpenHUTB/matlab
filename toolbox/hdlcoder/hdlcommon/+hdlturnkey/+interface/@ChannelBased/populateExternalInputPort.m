function populateExternalInputPort(hChannel,portName,portWidth,portDimension,TotalWidth,isComplex,portIdx,hElab)


    hChannel.ExtInportNames{end+1}=sprintf('%s_%s',hChannel.ChannelPortLabel,portName);

    if~hElab.hTurnkey.hD.isMLHDLC&&~hElab.hTurnkey.hD.isMDS&&hChannel.isFrameToSample

        if isComplex

            hChannel.ExtInportWidths{end+1}=portWidth;
            hChannel.ExtInportList.(portName).Width=portWidth;
            hChannel.ExtInportDimensions{end+1}=2;
        else
            hChannel.ExtInportWidths{end+1}=TotalWidth;
            hChannel.ExtInportList.(portName).Width=TotalWidth;
            hChannel.ExtInportDimensions{end+1}=1;
        end

    else

        if isComplex
            portDimension=2*portDimension;
        end


        if portDimension>1&&strcmp(hChannel.SamplePackingDimension,'All')
            hChannel.ExtInportWidths{end+1}=portWidth;
            hChannel.ExtInportList.(portName).Width=portWidth;
            hChannel.ExtInportDimensions{end+1}=portDimension;


        else
            hChannel.ExtInportWidths{end+1}=TotalWidth;
            hChannel.ExtInportList.(portName).Width=TotalWidth;
            hChannel.ExtInportDimensions{end+1}=1;
        end

    end

    hChannel.ExtInportTotalWidth{end+1}=TotalWidth;
    hChannel.ExtInportList.(portName).Index=portIdx;

end
