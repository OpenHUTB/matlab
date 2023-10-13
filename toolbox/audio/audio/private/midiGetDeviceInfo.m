function info=midiGetDeviceInfo(device)

%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        assert(nargin>0&&isa(device,'double')&&isreal(device)&&isscalar(device));

        coder.internal.errorIf(device<0||device>=midiCountDevices,...
        'audio:midi:MidiDeviceBadNumber',device);

        info=midimexif('midiGetDeviceInfo',device);
        info.interf=stripZeros(info.interf);
        info.name=stripZeros(info.name);

    else

        assert(nargin==1);
        assert(isa(device,'double')&&isscalar(device)&&isreal(device));

        info.interf=char(zeros(1,128));
        info.name=char(zeros(1,128));
        info.input=int32(0);
        info.output=int32(0);
        coder.cstructname(info,'DeviceInfo','extern');

        err=false;
        err(1)=coder.ceval('getDeviceInfoCpp',device,coder.wref(info));
        coder.internal.errorIf(err,'audio:midi:MidiDeviceUnknown');
    end
end


function str=stripZeros(str)
    str=str(1:find([str,char(0)]==0,1)-1);
end

