function count=midiCountDevices

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        count=midimexif('midiCountDevices');
    else

        count=coder.nullcopy(0);
        count=coder.ceval('countDevicesCpp');
    end
end
