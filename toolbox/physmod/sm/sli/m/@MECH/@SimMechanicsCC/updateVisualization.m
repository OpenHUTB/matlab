function updateVisualization(smc,source)




    ;
    obj=smc.up;
    while~isempty(obj)&&~strcmp(class(obj),'Simulink.BlockDiagram')
        obj=obj.up;
    end

    if~isempty(obj)
        obj=obj.Handle;
        msg=MECH.UpdateEnvironmentMessage;
        msg.send(obj);
    end



