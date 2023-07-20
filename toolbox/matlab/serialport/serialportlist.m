function ports=serialportlist(varargin)
















    narginchk(0,1);

    varargin=instrument.internal.stringConversionHelpers.str2char(varargin);

    if(nargin==0)
        options.PortFilter='all';
    else
        value=varargin{1};
        value=validatestring(value,{'all','available'},'seriallist','ports',1);
        if strcmpi(value,'all')
            options.PortFilter='all';
        else
            options.PortFilter='available';
        end
    end

    devicePlugin=fullfile(toolboxdir(fullfile('matlab','serialport','bin',computer('arch'))),'serialportlistdevice');
    converterPlugin=fullfile(toolboxdir(fullfile('matlab','serialport','bin',computer('arch'))),'serialportlistmlconverter');


    asyncIOChannel=matlabshared.asyncio.internal.Channel(devicePlugin,...
    converterPlugin,...
    Options=options,...
    StreamLimits=[0,0]);
    asyncIOChannel.execute("GetSerialList",options);


    ports=asyncIOChannel.ReturnSerialList;


    ports=string(ports);
end