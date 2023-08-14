classdef TextEditInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    methods
        function this=TextEditInteraction
            this.Type='textedit';
            this.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.DataTip;
            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.DoubleClick;
        end

        function response(obj,eventdata)%#ok<INUSD>
        end
    end

end
