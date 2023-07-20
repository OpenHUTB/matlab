function info=getAppInfo(app)




    info=[];
    if isempty(app)
        return;
    end

    dispKey=['ToolstripCoderApp:toolstrip:',app,'AppName'];
    targetsKey=['ToolstripCoderApp:toolstrip:',app,'AppTargets'];

    disp=message(dispKey).getString;
    targets=message(targetsKey).getString;

    info.name=app;
    info.disp=disp;
    info.targets=targets;

    switch app
    case 'EmbeddedCoder'
        info.action='embeddedCoderAppAction';
        info.stf='ert.tlc';
        info.appName='embeddedCoderApp';
    case 'SimulinkCoder'
        info.action='simulinkCoderAppAction';
        info.stf='grt.tlc';
        info.appName='simulinkCoderApp';
    case 'Autosar'
        info.action='autosarAppAction';
        info.stf='autosar.tlc';
        info.appName='autosarApp';
    case 'DDS'
        info.action='ddsAppAction';
        info.stf='ert.tlc';
        info.appName='ddsApp';
    end
