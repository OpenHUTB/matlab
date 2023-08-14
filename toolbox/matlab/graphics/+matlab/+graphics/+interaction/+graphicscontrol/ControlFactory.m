classdef ControlFactory<handle




    properties
Canvas
    end

    methods
        function this=ControlFactory(canvas)
            this.Canvas=canvas;
        end

        function cntrl=createControl(this,obj)
            controlManager=this.Canvas.ControlManager;
            cntrl=controlManager.findControl(obj);
            if isempty(cntrl)
                cntrl=this.createObjectControl(obj);
                controlManager.registerControl(obj,cntrl);
            end
        end
    end

    methods(Static)
        function cntrl=createObjectControl(obj)






            layoutable=isempty([ancestor(obj.NodeParent,'matlab.graphics.layout.Layout');...
            ancestor(obj.NodeParent,'matlab.graphics.internal.Layoutable')]);

            if isa(obj,'matlab.graphics.internal.Layoutable')||isa(obj,'matlab.graphics.layout.Layout')
                if(obj.isInGridLayout())
                    cntrl=matlab.graphics.interaction.graphicscontrol.layoutable.GridLayoutableControl(obj);
                else
                    cntrl=matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl(obj);
                end
            elseif isa(obj,'matlab.graphics.axis.AbstractAxes')
                if isa(obj,'matlab.graphics.axis.Axes')
                    cntrl=matlab.graphics.interaction.graphicscontrol.AxesControl(obj);
                elseif(obj.isInGridLayout())
                    cntrl=matlab.graphics.interaction.graphicscontrol.layoutable.GridLayoutableControl(obj);
                else
                    cntrl=matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControl(obj);
                end
            elseif isa(obj,'matlab.graphics.primitive.Text')
                cntrl=matlab.graphics.interaction.graphicscontrol.TextControl(obj);
            elseif isa(obj,'matlab.graphics.primitive.world.CompositeMarker')&&...
                strcmpi(obj.Description,'DataTipHoverMarker')
                cntrl=matlab.graphics.interaction.graphicscontrol.DataTipControl(obj);
            elseif isa(obj,'matlab.ui.controls.AxesToolbar')
                cntrl=matlab.graphics.interaction.graphicscontrol.AxesToolbarControl(obj);
            else

                cntrl=matlab.graphics.interaction.graphicscontrol.GenericControl();
            end

            if(isprop(cntrl,'Layoutable'))
                cntrl.Layoutable=layoutable;
            end
        end

        function cntrl=createLayoutableControl(canvas)
            cntrl=[];


            canvasChildren=allchild(canvas);
            if~isempty(canvasChildren)
                controlFactory=matlab.graphics.interaction.graphicscontrol.ControlFactory(canvas);
                for i=1:length(canvasChildren)
                    obj=canvasChildren(i);
                    if isa(obj,'matlab.graphics.internal.Layoutable')||...
                        isa(obj,'matlab.graphics.axis.AbstractAxes')||isa(obj,'matlab.graphics.layout.Layout')
                        cntrl=controlFactory.createControl(canvasChildren(i));
                    end
                end
            end
        end
    end
end
