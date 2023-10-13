function asiosettings(varargin)

    narginchk(0,1);
    nargoutchk(0,0);


    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);


    if~ispc()
        errID='audio:asiosettings:invalidOS';
        errMsg=getString(message(errID,'asiosettings'));
        error(errID,errMsg);
    end


    if~audioutil()
        errID='audio:audioutil:licenseNotFound';
        error(errID,getString(message(errID,'asiosettings')));
    end

    if length(varargin)==1
        deviceName=varargin{1};
        validateattributes(deviceName,{'char','string'},{'nonempty'},...
        'asiosettings','device',1);
        if strcmpi(deviceName,'Default')

            ID=getDefaultASIODeviceID();
        else
            deviceNameWithDriver=sprintf("%s (ASIO)",deviceName);

            devices=multimedia.internal.audio.device.DeviceInfo.getDevices();
            devices=devices(arrayfun(@(x)strcmp(x.HostApiName,'ASIO'),devices));
            ID=-1;
            for idx=1:length(devices)
                if strcmp(devices(idx).Name,deviceNameWithDriver)
                    ID=devices(idx).ID;
                    break;
                end
            end
        end
    else

        deviceName='Default';
        ID=getDefaultASIODeviceID();
    end

    if(ID==-1)
        errID='audio:asiosettings:deviceNotFound';
        errMsg=getString(message('audio:asiosettings:deviceNotFound',deviceName));
        error(errID,errMsg);
    else
        audio_asiosettings(ID);
    end

end

function deviceID=getDefaultASIODeviceID()


    deviceID=multimedia.internal.audio.device.DeviceInfo.getDefaultInputDeviceID(...
    multimedia.internal.audio.device.HostApi.ASIO);
end
