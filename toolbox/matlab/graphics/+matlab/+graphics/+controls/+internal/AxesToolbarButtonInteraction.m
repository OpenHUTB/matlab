classdef AxesToolbarButtonInteraction<...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction





    properties(Constant)
        LingerTime=1;
    end

    properties(Transient,NonCopyable)
        LingerListener;
        LingerExitListener;
        LingerObj;

        Toolbar;
        ResponseData;
    end

    methods
        function this=AxesToolbarButtonInteraction(obj,canvas)
            this@matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction();

            this.Type='AxesToolbarButtonEnterExit';

            this.Object=obj;
            this.Toolbar=ancestor(obj,'matlab.ui.controls.AxesToolbar');

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Exit;

            this.LingerObj=matlab.graphics.interaction.actions.Linger(this.Object);
            this.LingerObj.LingerTime=this.LingerTime;
            this.LingerListener=event.listener(this.LingerObj,'LingerOverObject',@(o,e)this.lingerCallback(o,e));
            this.LingerExitListener=event.listener(this.LingerObj,'ExitObject',@(o,e)this.lingerExitCallback(o,e));
            this.LingerObj.IncludeChildren=true;

            if~isempty(this.Toolbar)&&isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                controlFactory=matlab.graphics.interaction.graphicscontrol.ControlFactory(canvas);
                controlFactory.createControl(this.Toolbar);
                this.ResponseData=getObjectID(this.Toolbar);
            end

        end

        function lingerCallback(obj,~,~)
            if isa(obj.Object,'matlab.graphics.controls.internal.ToolTipMixin')
                obj.Object.showToolTip();
            end
        end

        function lingerExitCallback(obj,~,~)
            if isa(obj.Object,'matlab.graphics.controls.internal.ToolTipMixin')
                obj.Object.hideToolTip();
            end
        end

        function enterexitevent(obj,actionData)

            dropDown=ancestor(obj.Object,'matlab.ui.controls.ToolbarDropdown');

            switch(actionData.enterexit)
            case 'Entered'
                obj.Object.hover();

                if~isempty(dropDown)
                    dropDown.hover();
                end

                obj.LingerObj.enable();

            case 'ExitedObject'
                obj.LingerObj.disable();
                obj.Object.unhover();

                if~isempty(dropDown)
                    dropDown.doClose();
                end
            end
        end
    end
end

