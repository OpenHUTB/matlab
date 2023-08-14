function IOInfo=getIOInfo(boardName)




    IOInfo.LED.Value=0;
    IOInfo.LED.Logic='Active High';
    IOInfo.PB.Value=0;
    IOInfo.PB.Logic='Active High';
    IOInfo.DIP.Value=0;
    IOInfo.DIP.Logic='Active High';

    fpgaParams=soc.internal.getCustomBoardParams(boardName);
    extIOs=fpgaParams.fdevObj.externalIOInterfaces;

    for i=1:numel(extIOs)
        switch extIOs(i).Kind
        case 'LEDs'
            IOInfo.LED.Value=extIOs(i).PortWidth;
            IOInfo.LED.Logic=l_convertPolarityText(extIOs(i).Polarity);
        case 'PushButtons'
            IOInfo.PB.Value=extIOs(i).PortWidth;
            IOInfo.PB.Logic=l_convertPolarityText(extIOs(i).Polarity);
        case 'DIPSwitches'
            IOInfo.DIP.Value=extIOs(i).PortWidth;
            IOInfo.DIP.Logic=l_convertPolarityText(extIOs(i).Polarity);
        end
    end
end

function out=l_convertPolarityText(inputText)
    if strcmpi(inputText,'active_low')
        out='Active Low';
    else
        out='Active High';
    end
end
