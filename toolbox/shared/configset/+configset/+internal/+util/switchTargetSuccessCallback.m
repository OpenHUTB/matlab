function switchTargetSuccessCallback(cs)





    if isa(cs,'Simulink.RTWCC')
        cs=cs.getConfigSet;
    end
    if isa(cs,'Simulink.ConfigSet')
        controller=cs.getDialogController;
        if~isempty(controller.CoderDataView)
            controller.CoderDataView.onSourceBeingDestroyed;
            controller.CoderDataView=[];
        end
    end


