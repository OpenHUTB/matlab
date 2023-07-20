function prop=getConfigSetSettings(h,varargin)%#ok<INUSL>




    profEnable='off';
    if(nargin>0)
        device=varargin{1};
        splitName=regexp(device,'ARM\s*(?<family>\w+)','names');
        if(~isempty(splitName))
            if~strcmp(splitName.family,'Cortex')
                splitName=regexp(device,'(?<family>\d+)','names');
            end
            device=sprintf('ARM Compatible->ARM %s',splitName(1).family);
            profEnable='on';
        end
        device=strrep(device,' / ','->');
        hh=targetrepository.getHardwareImplementationHelper();
        deviceMatch=hh.getDevice(device);
        if isempty(deviceMatch)
            device='Intel Pentium';
        else
            device=deviceMatch.Alias{1};
        end
        stacksize=varargin{4};
    else
        device='Intel Pentium';
        stacksize=128*1024;
    end

    Fields={'Name','Method','Value'};
    Settings={'ProdHWDeviceType','setPropEnabled','on';
    'ProdHWDeviceType','set_param',device;...
    'ProdEndianess','setPropEnabled','on';...
    'Solver','setProp','FixedStepDiscrete';...
    'ProfileGenCode','set_param','off';...
    'ProfileGenCode','setPropEnabled',profEnable;...
    'ProdIntDivRoundTo','setPropEnabled','on';...
    'ProdIntDivRoundTo','set_param','Zero';...
    'systemStackSize','set_param',stacksize};

    prop=cell2struct(Settings,Fields,2);

