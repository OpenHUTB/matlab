classdef LayoutableControl<matlab.graphics.interaction.graphicscontrol.GenericControl




    properties
Obj
Layoutable
    end

    methods
        function this=LayoutableControl(obj)
            import matlab.graphics.interaction.*
            this=this@matlab.graphics.interaction.graphicscontrol.GenericControl();
            this.Obj=obj;
            this.Type='layoutable';
            this.Layoutable=true;
        end

        function setPositionForAutoResizableChildren(this,prop,value,frameSize)
            if isa(this.Obj,'matlab.graphics.internal.Layoutable')
                setPositionForAutoResizableChildren(this.Obj,prop,value,frameSize);
            elseif isa(this.Obj,'matlab.graphics.layout.Layout')


                setChartLayoutPositionForAutoResize(this.Obj);
            else
                matlab.graphics.internal.setPositionForAutoResizableChildren(this.Obj,prop,value,frameSize);
            end
        end

        function pos=getPositionForAutoResizableChildren(this,prop)
            if isa(this.Obj,'matlab.graphics.internal.Layoutable')
                pos=getPositionForAutoResizableChildren(this.Obj,prop);
            elseif isa(this.Obj,'matlab.graphics.layout.Layout')


                fig=ancestor(this.Obj,'figure');
                container=ancestor(this.Obj,'matlab.ui.internal.mixin.CanvasHostMixin');

                pos=hgconvertunits(fig,[0,0,1,1],'normalized','pixels',container);
            else
                pos=matlab.graphics.internal.getPositionForAutoResizableChildren(this.Obj,prop);
            end
        end

        function response=process(this,message)
            response=struct;
            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.setOuterPosition
                    this.setPositionForAutoResizableChildren('OuterPosition',message.data,message.refFrameDim);
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.setInnerPosition
                    this.setPositionForAutoResizableChildren('InnerPosition',message.data,message.refFrameDim);
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.getInnerPosition
                    response.InnerPosition=this.getPositionForAutoResizableChildren('InnerPosition');
                case matlab.graphics.interaction.graphicscontrol.layoutable.LayoutableControlEnums.getOuterPosition
                    response.OuterPosition=this.getPositionForAutoResizableChildren('OuterPosition');
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.GenericControl(this,message);
                end
            end
        end
    end
end
