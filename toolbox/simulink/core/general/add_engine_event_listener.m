function add_engine_event_listener(model,eventType,listenerCallback)

















































    if nargin~=3,
        DAStudio.error('Simulink:utility:NumInputMismatch',3);
    end

    bdh=get_param(model,'slobject');

    if isempty(bdh)
        DAStudio.error('Simulink:utility:BDNotExecuting');
    end



    p=findprop(bdh,'Listener_Storage_');
    if isempty(p)
        p=addprop(bdh,'Listener_Storage_');
        p.Hidden=1;
    end




    bdListeners=bdh.Listener_Storage_;
    for i=1:length(bdListeners)
        cb=bdListeners(i).Callback;
        if isequal(cb,listenerCallback)
            return;
        end
    end




    hl=addlistener(bdh,eventType,listenerCallback);

    hl=[bdh.Listener_Storage_;hl];
    bdh.Listener_Storage_=hl;


