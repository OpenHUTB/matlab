function addContainerListeners(fig,hMode)










    uicontainers=findall(allchild(fig),'flat','-isa','matlab.ui.internal.mixin.CanvasHostMixin');


    hMode.ModeStateData.ContainerListeners=[];
    localChildAdded(fig,hMode);

    if~isempty(uicontainers)

        uicontainers=findall(fig,'-isa','matlab.ui.internal.mixin.CanvasHostMixin');
        for k=1:length(uicontainers)
            uicontainers(k).getCanvas;
            localChildAdded(uicontainers(k),hMode);
        end
    end

    function localChildAdded(h,hMode)




        if~ishghandle(h,'uipanel')&&~ishghandle(h,'uicontainer')&&~ishghandle(h,'figure')
            return
        end


        h.getCanvas;






        hMode.ModeStateData.ContainerListeners=[hMode.ModeStateData.ContainerListeners;...
        event.listener(h,'ObjectChildAdded',@(e,d)localChildAdded(d.Child,hMode))];