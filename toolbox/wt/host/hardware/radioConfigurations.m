function varargout=radioConfigurations(varargin)














    p=inputParser;
    addParameter(p,'Hardware','');
    parse(p,varargin{:});
    hardware=p.Results.Hardware;


    d=wt.internal.hardware.DeviceStore;
    out=struct('Name','','Hardware','','IPAddress','');
    out(1)=[];
    n=1;
    for k=1:numel(d.Names)
        devParams=getDeviceParameters(d,d.Names{k});
        if isempty(hardware)
            out(n)=i_getConfigStruct(d.Names{k},devParams);
            n=n+1;
        elseif strcmpi(hardware,devParams.Type)

            out(n)=i_getConfigStruct(d.Names{k},devParams);
            n=n+1;
        end
    end

    if nargout==1

        varargout{1}=out;
    else

        fprintf('\nRadio configurations:\n\n')
        for k=1:numel(out)
            fprintf('       Name: "%s"\n',out(k).Name);
            fprintf('   Hardware: "%s"\n',out(k).Hardware);
            fprintf('  IPAddress: "%s"\n\n',out(k).IPAddress);
        end
    end
end


function out=i_getConfigStruct(devName,devParams)
    out.Name=string(devName);
    out.Hardware=string(devParams.Type);
    if~isempty(devParams.Network.DeviceIP0)
        out.IPAddress=string(devParams.Network.DeviceIP0);
    else
        out.IPAddress=string(devParams.Network.DeviceIP1);
    end
end