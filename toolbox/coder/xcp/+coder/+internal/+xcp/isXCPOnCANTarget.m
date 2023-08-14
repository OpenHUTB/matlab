function ret=isXCPOnCANTarget(cs)





    ret=false;

    assert(~isempty(cs)&&(isa(cs,'Simulink.ConfigSet')||isa(cs,'Simulink.ConfigSetRef')),...
    'isXCPOnCANTarget: invalid config set');






    if~cs.isValidParam('ExtMode')||...
        strcmp(get_param(cs,'ExtMode'),'off')||...
        ~cs.isValidParam('ExtModeTransport')
        return;
    end


    transportIndex=get_param(cs,'ExtModeTransport');


    transports=extmode_transports(cs);
    assert(transportIndex<length(transports),...
    'isXCPOnCANTarget: ExtModeTransport parameter value is invalid.');

    transportName=char(transports(transportIndex+1));

    ret=strcmp(transportName,Simulink.ExtMode.Transports.XCPCAN.Transport);

end
