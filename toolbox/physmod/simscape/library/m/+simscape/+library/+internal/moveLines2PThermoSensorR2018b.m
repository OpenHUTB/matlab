function moveLines2PThermoSensorR2018b(thermoBlock)








    isLocked=get_param(bdroot,'Lock');
    set_param(bdroot,'Lock','off');

    system=get_param(thermoBlock,'Parent');
    connections=get_param(thermoBlock,'PortConnectivity');
    dstPorts=connections(5).DstPort;

    if~isempty(dstPorts)

        thermoPosition=get_param(thermoBlock,'Position');
        thermoCommented=get_param(thermoBlock,'Commented');

        vaporBlock=add_block(sprintf('fl_lib/Two-Phase Fluid/Sensors/Vapor Quality Sensor\n(2P)'),...
        sprintf([system,'/Vapor Quality Sensor\n(2P)']),'MakeNameUnique','on',...
        'Position',thermoPosition+[0,45,0,45]);

        set_param(vaporBlock,'Commented',thermoCommented);

        thermoPortList=get_param(thermoBlock,'PortHandles');
        vaporPortList=get_param(vaporBlock,'PortHandles');

        add_line(system,thermoPortList.LConn(1),vaporPortList.LConn(1),'autorouting','on')

        for i=1:length(dstPorts)
            delete_line(get_param(dstPorts(i),'Line'))
        end

        for i=1:length(dstPorts)
            add_line(system,vaporPortList.RConn(1),dstPorts(i),'autorouting','on')
        end
    end


    set_param(bdroot,'Lock',isLocked);

end