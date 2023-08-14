function varargout=RadioDevice(varargin)



























    ds=wt.internal.hardware.DeviceStore;
    if nargin==0
        if nargout==0
            printHelp(ds.Names);
        else

            varargout{1}=ds.Names;
        end
    else

        if ischar(varargin{1})||isstring(varargin{1})
            devName=varargin{1};
            devParams=getDeviceParameters(ds,devName);
        elseif isstruct(varargin{1})




            devParams=varargin{1};
        else
            error(message('wt:radio:InvalidRadio'));
        end


        pm=wt.internal.hardware.PluginManager.getInstance();
        plugin=pm.getPlugin(devParams.Type);

        devPlugin=eval([plugin.Device,'(plugin)']);


        devPlugin.SFP0IPAddress=devParams.Network.DeviceIP0;
        devPlugin.SFP1IPAddress=devParams.Network.DeviceIP1;
        if~isequal(devParams.Type,'X310')
            if~isempty(devPlugin.SFP1IPAddress)
                devPlugin.ManagementIPAddress=devPlugin.SFP1IPAddress;
            else
                devPlugin.ManagementIPAddress=devPlugin.SFP0IPAddress;
            end
        end


        varargout{1}=devPlugin;
    end
end

function printHelp(devNames)
    deviceList=newline;
    for dev=devNames
        deviceList=[deviceList,sprintf('\t''%s''\n',dev{1})];%#ok<AGROW>
    end
    deviceMessage=message("wt:radio:ChooseDevice",deviceList);
    disp(deviceMessage.getString());
end
