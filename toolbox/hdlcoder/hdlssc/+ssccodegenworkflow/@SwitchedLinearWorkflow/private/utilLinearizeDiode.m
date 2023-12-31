function utilLinearizeDiode(hdiodeSystem,diodeValues,hdiode,diodeNum,inputFlip)






    Rs=diodeValues.Rs;
    diodeSystem=getfullname(hdiodeSystem);

    portConnectivity=get_param(hdiode,'PortConnectivity');
    hLconn=portConnectivity(2).DstBlock;
    hRconn=portConnectivity(1).DstBlock;

    if~inputFlip
        set_param(hRconn,'Orientation','right')
        set_param(hLconn,'Orientation','left')
        set_param(hRconn,'Name','+')
        set_param(hLconn,'Name','-')
        set_param(hRconn,'Position',[195,178,225,192])
        set_param(hLconn,'Position',[630,198,660,212])
        anodeName=strcat(get_param(hRconn,'name'),'/Rconn1');
        cathodeName=strcat(get_param(hLconn,'name'),'/Rconn1');
    else
        set_param(hLconn,'Orientation','right')
        set_param(hRconn,'Orientation','left')
        set_param(hRconn,'Name','-')
        set_param(hLconn,'Name','+')
        set_param(hLconn,'Position',[195,178,225,192])
        set_param(hRconn,'Position',[630,198,660,212])
        cathodeName=strcat(get_param(hRconn,'name'),'/Rconn1');
        anodeName=strcat(get_param(hLconn,'name'),'/Rconn1');
    end




    diodePorts=get_param(hdiode,'porthandles');
    delete_line(get_param(diodePorts.LConn,'Line'));
    delete_line(get_param(diodePorts.RConn,'Line'));
    delete_block(hdiode);





    hResistor=add_block('fl_lib/Electrical/Electrical Elements/Resistor',strcat(diodeSystem,'/Rs'),...
    'MakeNameUnique','on',...
    'R',num2str(Rs,17),...
    'Position',[325,211,365,239]);
    hCurrentSource=add_block('fl_lib/Electrical/Electrical Sources/Controlled Current Source',strcat(diodeSystem,'/Controlled Current Source'),...
    'MakeNameUnique','on',...
    'Orientation','right',...
    'Position',[325,165,365,205]);
    hCurrentSensor=add_block('fl_lib/Electrical/Electrical Sensors/Current Sensor',strcat(diodeSystem,'/Current Sensor'),...
    'MakeNameUnique','on',...
    'Orientation','right',...
    'Position',[420,175,460,215]);
    hVoltageSensor=add_block('fl_lib/Electrical/Electrical Sensors/Voltage Sensor',strcat(diodeSystem,'/Voltage Sensor'),...
    'MakeNameUnique','on',...
    'Orientation','right',...
    'Position',[325,100,365,140]);


    hCurrentSensorPSS=add_block('nesl_utility/PS-Simulink Converter',strcat(diodeSystem,'/HDLLinDiodeCurrent',num2str(diodeNum)),...
    'MakeNameUnique','on',...
    'Orientation','up',...
    'Position',[462,140,478,155]);
    hVoltageSensorPSS=add_block('nesl_utility/PS-Simulink Converter',strcat(diodeSystem,'/HDLLinDiodeVoltage',num2str(diodeNum)),...
    'MakeNameUnique','on',...
    'Orientation','up',...
    'Position',[-113,110,-97,125]);
    hCurrentSourceSPS=add_block('nesl_utility/Simulink-PS Converter',strcat(diodeSystem,'/HDLLinDiodeJ',num2str(diodeNum)),...
    'MakeNameUnique','on',...
    'Orientation','down',...
    'Position',[557,115,573,130]);

    hCurrentDelay=add_block('simulink/Discrete/Unit Delay',strcat(diodeSystem,'/Unit Delay'),...
    'MakeNameUnique','on',...
    'Orientation','up',...
    'Position',[453,85,487,120]);
    hVoltageDelay=add_block('simulink/Discrete/Unit Delay',strcat(diodeSystem,'/Unit Delay1'),...
    'MakeNameUnique','on',...
    'Position',[-90,58,-55,92]);
    hSDelay=add_block('simulink/Discrete/Unit Delay',strcat(diodeSystem,'/Unit Delay2'),...
    'MakeNameUnique','on',...
    'Position',[218,-110,252,-75]);


    utilDiodeLogic(strcat(get_param(hVoltageDelay,'name'),'/1'),...
    strcat(get_param(hCurrentDelay,'name'),'/1'),...
    strcat(get_param(hSDelay,'name'),'/1'),...
    strcat(get_param(hCurrentSourceSPS,'name'),'/1'),...
    strcat(get_param(hSDelay,'name'),'/1'),...
    diodeSystem,diodeValues,'double')



    outPorts={strcat(get_param(hCurrentSensorPSS,'name'),'/Lconn1'),...
    strcat(get_param(hVoltageSensorPSS,'name'),'/Lconn1'),...
    strcat(get_param(hCurrentSourceSPS,'name'),'/Rconn1'),...
    strcat(get_param(hCurrentSensorPSS,'name'),'/1'),...
    strcat(get_param(hVoltageSensorPSS,'name'),'/1')};


    inPorts={strcat(get_param(hCurrentSensor,'name'),'/Rconn1'),...
    strcat(get_param(hVoltageSensor,'name'),'/Rconn1'),...
    strcat(get_param(hCurrentSource,'name'),'/Rconn1'),...
    strcat(get_param(hCurrentDelay,'name'),'/1'),...
    strcat(get_param(hVoltageDelay,'name'),'/1')};

    add_line(diodeSystem,outPorts,inPorts,'AutoRouting','smart')

    add_line(diodeSystem,anodeName,strcat(get_param(hResistor,'name'),'/Lconn1'),...
    'AutoRouting','on');
    add_line(diodeSystem,strcat(get_param(hResistor,'name'),'/Rconn1'),strcat(get_param(hCurrentSensor,'name'),'/Lconn1'),...
    'AutoRouting','on');

    add_line(diodeSystem,anodeName,strcat(get_param(hCurrentSource,'name'),'/Lconn1'),...
    'AutoRouting','on');
    add_line(diodeSystem,strcat(get_param(hCurrentSource,'name'),'/Rconn2'),strcat(get_param(hCurrentSensor,'name'),'/Lconn1'),...
    'AutoRouting','on');

    add_line(diodeSystem,anodeName,strcat(get_param(hVoltageSensor,'name'),'/Lconn1'),...
    'AutoRouting','on');
    add_line(diodeSystem,strcat(get_param(hVoltageSensor,'name'),'/Rconn2'),strcat(get_param(hCurrentSensor,'name'),'/Lconn1'),...
    'AutoRouting','on');

    add_line(diodeSystem,strcat(get_param(hCurrentSensor,'name'),'/Rconn2'),cathodeName,...
    'AutoRouting','on');


end


