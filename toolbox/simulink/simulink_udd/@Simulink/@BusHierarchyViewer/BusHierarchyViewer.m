function h=BusHierarchyViewer(model)





    h=Simulink.BusHierarchyViewer;

    h.fModel=model;

    h.fListener=Simulink.listener(get_param(model,'Object'),...
    'CloseEvent',@(handle,eventData)delete(h));

end
