function handle=getPortHandle(block,portname)














    blockHandle=get_param(block,'Handle');
    ports=get_param(blockHandle,'PortHandles');


    handles=[ports.LConn,ports.RConn];

    for i=1:numel(handles)
        trialName=builtin('_simscape_gl_sli_get_port_name',blockHandle,...
        handles(i));
        if strcmp(portname,trialName)
            handle=handles(i);
            return;
        end
    end


    handle=-1;
