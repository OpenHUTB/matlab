function massToolstripEnable(obj,finishedGeneration)




    for section=[obj.pWavegenTab.Children,obj.pRadioTab.Children]
        for column=section.Children
            for item=column.Children
                if~isa(item,'matlab.ui.internal.toolstrip.EmptyControl')

                    if strcmp(item.Tag,'waveformGallery')

                        item.Enabled=finishedGeneration&&~strcmp(obj.pCurrentWaveformType,'UNKNOWN');

                    elseif strcmp(item.Tag,'generate')

                        if strcmp(obj.pCurrentWaveformType,'UNKNOWN')
                            item.Enabled=finishedGeneration&&obj.pParameters.ImpairDialog.impaired();
                        else
                            item.Enabled=finishedGeneration;
                        end

                    elseif strcmp(item.Tag,'findHardware')
                        item.Enabled=finishedGeneration&&~isempty(obj.pParameters.RadioDialog)&&supportScanning(obj.pParameters.RadioDialog);

                    elseif any(strcmp(item.Tag,{'transmitWaveform','exportMLfromTransmit'}))
                        item.Enabled=finishedGeneration&&~isempty(obj.pParameters.RadioDialog)&&canTransmit(obj.pParameters.RadioDialog);

                    else
                        item.Enabled=finishedGeneration;
                    end
                end
            end
        end
    end