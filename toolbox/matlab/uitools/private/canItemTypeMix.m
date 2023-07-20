function mixType=canItemTypeMix(item1,item2)















    mixType=isequal(getMixedTypeGroup(item1),getMixedTypeGroup(item2));


    function group=getMixedTypeGroup(item)
        item=handle(item);
        group=class(item);
        if ishghandle(item)
            if(isa(item,'matlab.ui.control.ClientComponent')||...
                isa(item,'matlab.ui.internal.mixin.CanvasHostMixin')||...
                isa(item,'matlab.ui.container.TabGroup'))
                group='uicomponent';
            elseif(isa(item,'matlab.graphics.primitive.world.SceneNode')&&...
                ~isa(item,'matlab.graphics.shape.internal.AnnotationPane'))
                group='graphicscomponent';
            end
        end
