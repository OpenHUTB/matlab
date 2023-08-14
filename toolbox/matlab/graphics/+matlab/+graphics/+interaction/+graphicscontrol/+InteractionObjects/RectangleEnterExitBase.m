classdef RectangleEnterExitBase<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase



    properties(Access=private)
    end

    methods
        function this=RectangleEnterExitBase
            this.Type='rectenterexit';
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.RectangleEnterExit;
            this.PickStrategy=1;
        end

        function response(this,eventdata)
            switch eventdata.name
            case 'RectangleEnter'
                this.RectangleEnter(eventdata);
            case 'RectangleExit'
                this.RectangleExit(eventdata);
            end
        end
    end

    methods(Abstract)
        RectangleEnter(this,evd)
        RectangleExit(this,evd)
    end
end
