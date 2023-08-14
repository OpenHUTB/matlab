classdef AxesToolbarControl<matlab.graphics.interaction.graphicscontrol.GenericControl



    properties
Obj
    end

    methods
        function this=AxesToolbarControl(obj)
            this=this@matlab.graphics.interaction.graphicscontrol.GenericControl();
            this.Type='AxesToolbar';
            this.Obj=obj;
        end

        function response=process(this,message)
            response=struct;



            this.Obj.setPosition(this.Obj.Parent);

            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case 'setAlphaMultiplier'
                    this.setAlphaMultiplier(message.value);
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.GenericControl(this,message);
                end
            end
        end
    end

    methods
        function setAlphaMultiplier(this,val)
            if this.Obj.Opacity==val
                return;
            end

            switch(val)
            case 1
                this.Obj.show();
            case 0
                this.Obj.hide();
            end
        end
    end
end
