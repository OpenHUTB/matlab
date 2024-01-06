function drawEventConnectors(model)

    if isequal(get_param(model,'Shown'),'off')
        return;
    end
    ecm=sltp.internal.EventConnectorManager(model);
    ecm.draw();

end
