function device=midiGetDefaultInputDevice

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        device=midimexif('midiGetDefaultInputDevice');
    else

        device=coder.nullcopy(double(0));
        device=coder.ceval('getDefaultInputDeviceCpp');
        if device<0

        end
    end
end
